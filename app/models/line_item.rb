class LineItem < ApplicationRecord
  belongs_to :meal
  belongs_to :order
  has_many :inventory_units, as: :trackable
  has_many :meal_ingredients, through: :meal

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0, allow_blank: true }
  validates :meal, uniqueness: { scope: :order }
  validate :stock_available, if: :quantity?
  after_save :validate_all_meals_in_order_in_stock

  scope :reverse_chronological_order, -> { order(updated_at: :desc) }

  private def stock_available
    max_qty = meal.max_available_quantity_at_location(order.location)
    errors.add(:base, I18n.t('models.line_item.max_allowable_quantity.failure', max_qty: max_qty)) if quantity > max_qty
  end

  private def validate_all_meals_in_order_in_stock
    return if order.valid?

    order.errors.each do |error|
      errors.add(:base, error.full_message)
    end
    raise ActiveRecord::RecordInvalid if errors.any?
  end

  def cost
    meal.total_price * quantity
  end
end
