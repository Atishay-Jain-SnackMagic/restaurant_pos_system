class Order < ApplicationRecord
  include Tokenable

  ORDER_CANCELLATION_TIME_DIFFERENCE = 30.minutes
  TIME_OFFSET = 5.5

  belongs_to :user
  belongs_to :location
  has_many :line_items, dependent: :destroy, autosave: true
  has_many :payments, dependent: :destroy
  has_many :meals, through: :line_items

  acts_as_tokenable column: :number, prefix: 'O', length: 10

  enum :fulfilment_status, { received: 0, ready: 1, picked_up: 2 }
  enum :state, { cart: 0, complete: 1, cancelled: 2 }

  validate :validate_stock_availablility, if: :cart?
  validates :mobile_number, :pickup_time, presence: true, if: :complete?
  validates :pickup_time, current_date: { allow_blank: true }, if: :pickup_time_changed?
  validates :cancelled_at, presence: true, if: :cancelled?
  validate :ensure_cancellation_time_allowed, if: :cancelled_at?

  after_save :ensure_have_max_one_succeeded_payment

  before_update :clear_cart, if: :location_changed?
  before_create :generate_token
  
  def mark_cancelled!
    update!(state: :cancelled, cancelled_at: TIME_OFFSET.hours.from_now)
  end  

  private def validate_stock_availablility
    errors.add(:base, :insufficient_inventory) if inventory_insufficient_for_line_items?
  end

  private def inventory_insufficient_for_line_items?
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
    line_items
      .joins(meal: { meal_ingredients: :ingredient })
      .select('SUM(line_items.quantity * meal_ingredients.quantity * ingredients.unit_price) AS total_cost')
      .take.total_cost || 0
  end

  def total_amount_cents
    (total_cost * 100).to_i
  end

  private def ensure_have_max_one_succeeded_payment
    if payments.succeeded.count > 1
      errors.add(:payment, I18n.t('models.order.validations.payment.already_completed'))
      raise ActiveRecord::RecordInvalid
    end
  end

  private def ensure_cancellation_time_allowed
    return if cancelled_at.in_time_zone('New Delhi') < cut_off_cancelled_time

    errors.add(:cancelled_time, "should be at least #{ORDER_CANCELLATION_TIME_DIFFERENCE.inspect} before the pickup time")
  end

  private def cut_off_cancelled_time
    pickup_time - ORDER_CANCELLATION_TIME_DIFFERENCE
  end
end
