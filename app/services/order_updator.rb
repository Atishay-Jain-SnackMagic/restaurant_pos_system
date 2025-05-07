class OrderUpdator
  attr_reader :order

  def initialize(order)
    @order = order
  end

  # Update order totals and line item totals
  def refresh_totals
    ActiveRecord::Base.transaction do
      order.line_items.includes(meal: :ingredients).each do |line_item|
        line_item.update_column(:unit_price, line_item.meal.total_price)
      end
      order.update_total_amount
    end
  end
end
