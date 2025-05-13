class OrderCheckoutService
  attr_reader :order, :params

  def initialize(order, params)
    @order = order
    @params = params
  end

  def process
    validate_order
    return if order.errors.present?

    order.update(order_checkout_params)
    begin
      order.mark_payment! unless order.errors.present?
    rescue ActiveRecord::RecordInvalid, Workflow::TransitionHalted
    end
  end

  def validate_order
    OrderValidator.new(order).validate
    validate_pickup_time
  end

  def validate_pickup_time
    return if pickup_time.blank?

    pickup_time_greater_than_current_time && pickup_time_valid_for_location
  end

  private def pickup_time_greater_than_current_time
    return true if pickup_time >= Time.current

    order.errors.add(:pickup_time, :pickup_time_invalid)
  end

  private def pickup_time_valid_for_location
    return true if order.location.opening_time.to_fs(:time) <= pickup_time.to_fs(:time) && order.location.closing_time.to_fs(:time) >= pickup_time.to_fs(:time)

    order.errors.add(:pickup_time, :pickup_time_unavailable)
  end

  private def order_checkout_params
    params.expect(order: [ :pickup_time, :mobile_number ])
  end

  private def pickup_time
    @pickup_time ||= Time.parse(params[:order][:pickup_time])
  end
end
