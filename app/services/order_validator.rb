class OrderValidator
  attr_reader :order

  def initialize(order)
    @order = order
  end

  def validate
    return unless order.valid?

    order.errors.add(:base, :insufficient_inventory) if OrderLineItemsAdjuster.new(order).inventory_insufficient_for_line_items?
    order.errors.add(:total_amount, :price_changed) if order.price_changed?
    order.errors.add(:base, :meal_inactive) unless order.meals.all?(&:is_active?)
  end
end
