class Order < ApplicationRecord
  include Tokenable

  belongs_to :user
  belongs_to :location
  has_many :line_items, dependent: :destroy

  acts_as_tokenable column: :number, prefix: 'O', length: 10

  enum :fulfilment_status, { received: 0, ready: 1, picked_up: 2 }
  enum :state, { cart: 0, complete: 1, cancelled: 2 }

  before_create :generate_token

  def inventory_insufficient_for_line_items?
    line_items
      .left_joins(meal: { meal_ingredients: :inventory_locations })
      .where(inventory_locations: { location_id: [ location_id, nil ] })
      .group(meal_ingredients: :ingredient_id, inventory_locations: :id)
      .having('SUM(line_items.quantity * meal_ingredients.quantity) > COALESCE(inventory_locations.quantity, 0)')
      .any?
  end

  def clear_cart
    line_items.destroy_all
  end

  def update_total_amount
    update_column(:total_amount, total_cost)
  end

  def total_cost
    line_items.sum(&:cost)
  end
end
