class OrderCancelService
  attr_reader :order

  def initialize(order)
    @order = order
  end

  def process
    return unless order

    validate_order
    return if order.errors.present?

    order.mark_cancelled!
  rescue ActiveRecord::RecordInvalid, Workflow::TransitionHalted
  end

  private def validate_order
    return if order.can_cancel?

    order.errors.add(:base, :cancellation_not_allowed, time_difference: ORDER::ORDER_CANCELLATION_TIME_DIFFERENCE.inspect)
  end
end
