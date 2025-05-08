class LineItem < ApplicationRecord
  belongs_to :meal
  belongs_to :order
  has_many :inventory_units, dependent: :destroy
  has_many :meal_ingredients, through: :meal

  attr_accessor :skip_update_order_amount

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0, allow_blank: true }
  validates :meal, uniqueness: { scope: :order }
  validate :stock_available, if: [ :quantity?, :order_id? ], unless: :order_completed_at?

  before_save :set_unit_price
  after_commit :update_order_amount, unless: :skip_update_order_amount

  scope :reverse_chronological_order, -> { order(updated_at: :desc) }

  delegate :completed_at?, to: :order, allow_nil: true, prefix: true

  private def stock_available
    max_qty = meal.max_available_quantity_at_location(order.location)
    errors.add(:base, :max_allowable_quantity, max_qty: max_qty) if quantity > max_qty
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
