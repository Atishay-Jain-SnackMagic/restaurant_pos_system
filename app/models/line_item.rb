class LineItem < ApplicationRecord
  belongs_to :meal
  belongs_to :order
  has_many :inventory_units, dependent: :destroy
  has_many :meal_ingredients, through: :meal

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0, allow_blank: true }
  validates :meal, uniqueness: { scope: :order }
  validate :stock_available, if: [ :quantity?, :order_cart? ]

  before_save :set_unit_price
  after_commit :update_order_amount

  scope :reverse_chronological_order, -> { order(updated_at: :desc) }

  private def stock_available
    max_qty = meal.max_available_quantity_at_location(order.location)
    errors.add(:base, I18n.t('models.line_item.max_allowable_quantity.failure', max_qty: max_qty)) if quantity > max_qty
  end

  private def order_cart?
    order&.cart?
  end

  def cost
    unit_price * quantity
  end

  private def set_unit_price
    self.unit_price = meal.price
  end

  private def update_order_amount
    order.update_total_amount
  end
end
