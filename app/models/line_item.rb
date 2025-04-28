class LineItem < ApplicationRecord
  belongs_to :meal
  belongs_to :order
  has_many :inventory_units, as: :trackable

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0, allow_blank: true }
  validates :meal, uniqueness: { scope: :order }
  validate :meal_max_quantity, if: :quantity?
  after_save :validate_order

  scope :reverse_chronological_order, -> { order(updated_at: :desc) }

  private def meal_max_quantity
    max_qty = meal.max_quantity_at_location(order.location)
    errors.add(:base, I18n.t('models.line_item.max_allowable_quantity.failure', max_qty: max_qty)) if quantity > max_qty
  end

  private def validate_order
    return if order.valid?

    order.errors.each do |error|
      errors.add(:cart, error.full_message)
    end
    raise ActiveRecord::RecordInvalid if errors.any?
  end

  def cost
    meal.total_price * quantity
  end
end
