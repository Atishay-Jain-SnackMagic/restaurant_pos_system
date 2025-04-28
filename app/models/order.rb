class Order < ApplicationRecord
  OFFSET = 12345

  belongs_to :user
  belongs_to :location
  has_many :line_items, dependent: :destroy

  enum :fulfilment_status, { received: 0, ready: 1, picked_up: 2 }
  enum :state, { cart: 0, complete: 1, cancelled: 2 }

  validate :total_ingredients_used

  before_update :destroy_line_items, if: :location_changed?
  after_create :set_unique_code

  private def total_ingredients_used
    inv = InventoryLocation.where(location_id: location_id).index_by(&:ingredient_id)
    used_ing_hash = line_items.includes(meal: :meal_ingredients).each_with_object(Hash.new(0)) do |item, hash|
      item.meal.meal_ingredients.each do |meal_ing|
        hash[meal_ing.ingredient_id] += item.quantity * meal_ing.quantity
      end
    end

    if used_ing_hash.any? { |ing, val| (inv[ing]&.quantity || 0) < val }
      errors.add(:base, I18n.t('models.order.validations.total_ingredients.failure'))
    end
  end

  private def destroy_line_items
    line_items.destroy_all
  end

  private def set_unique_code
    scrambled_id = id + OFFSET
    update_column(:unique_code, "o#{scrambled_id.to_s(36).rjust(5, '0')}")
  end

  def auto_adjust_line_items
    inv = InventoryLocation.where(location_id: location_id).index_by(&:ingredient_id)
    running_inventory = inv.transform_values(&:quantity)

    line_items.includes(meal: :meal_ingredients).reverse_chronological_order.each do |item|
      max_possible = item.meal.meal_ingredients.map { |mi| (running_inventory[mi.ingredient_id] || 0) / mi.quantity }.min

      if max_possible > 0
        item.update_column(:quantity, max_possible) if item.quantity > max_possible
        item.meal.meal_ingredients.each { |mi| running_inventory[mi.ingredient_id] -= item.quantity * mi.quantity }
      else
        item.destroy
      end
    end
  end

  def line_item_by_meal(meal)
    line_items.detect { |item| item.meal_id == meal&.id }
  end

  def total_cost
    line_items.includes(meal: :ingredients).sum(&:cost)
  end
end
