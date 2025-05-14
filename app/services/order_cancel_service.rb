class OrderCancelService
  TIME_OFFSET = 5.5

  attr_reader :order

  def initialize(order)
    @order = order
  end

  def process
    return unless order

    validate_cancellation_time
    return if order.errors.present?

    order.mark_cancelled!
  rescue ActiveRecord::RecordInvalid, Workflow::TransitionHalted
  end

  private def validate_cancellation_time
    return if TIME_OFFSET.hours.from_now < order.cut_off_cancelled_time

    order.errors.add(:base, :cancellation_time_invalid, time_difference: Order::ORDER_CANCELLATION_TIME_DIFFERENCE.inspect)
  end
end
