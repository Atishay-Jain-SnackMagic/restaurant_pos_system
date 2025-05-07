class OrderUpdator
  attr_reader :order, :order_line_items_adjuster

  def initialize(order)
    @order = order
    @order_line_items_adjuster = OrderLineItemsAdjuster.new(order)
  end

  def update
    ActiveRecord::Base.transaction do
      order_line_items_adjuster.adjust_line_items
      refresh_totals
    end
    order_line_items_adjuster.line_items_adjusted
  end

  # Update order totals and line item totals
  private def refresh_totals
    ActiveRecord::Base.transaction do
      order.line_items.includes(meal: :ingredients).each do |line_item|
        line_item.update_column(:unit_price, line_item.meal.total_price)
      end
      order.update_total_amount
    end
  end
end
