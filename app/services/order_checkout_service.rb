class OrderCheckoutService
  attr_reader :order, :params, :pickup_time

  def initialize(order, params)
    @order = order
    @params = params
    @pickup_time = parse_pickup_time
  end

  def process
    validate_order
    order.update(order_checkout_params) unless order.errors.any?
  end

  def validate_order
    validate_pickup_time
    order.errors.add(:base, :insufficient_inventory) if OrderLineItemsAdjuster.new(order).inventory_insufficient_for_line_items?
    order.errors.add(:total_amount, :price_changed) if order.price_changed?
  end

  def validate_pickup_time
    pickup_time_greater_than_current_time? && pickup_time_valid_for_location?
  end

  private def pickup_time_greater_than_current_time?
    return true if pickup_time.blank? || pickup_time >= Time.current

    order.errors.add(:pickup_time, :pickup_time_invalid)
    false
  end

  private def pickup_time_valid_for_location?
    return true if pickup_time.blank? || (order.location.opening_time.to_fs(:time) <= pickup_time.to_fs(:time) && order.location.closing_time.to_fs(:time) >= pickup_time.to_fs(:time))

    order.errors.add(:pickup_time, :pickup_time_unavailable)
    false
  end

  private def order_checkout_params
    params.expect(order: [ :pickup_time, :mobile_number ])
  end

  private def parse_pickup_time
    Time.parse(params[:order][:pickup_time])
  end
end
