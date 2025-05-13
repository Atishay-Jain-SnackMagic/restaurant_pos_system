class PaymentManager
  attr_reader :payment, :order

  def initialize(payment)
    @payment = payment
    @order = payment&.order
  end

  def process
    return unless payment.present?

    payment_intent = Stripe::PaymentIntent.retrieve(payment.stripe_id)
    return payment.mark_failed! unless payment_intent.status == 'succeeded'

    raise ActiveRecord::RecordInvalid unless valid_order_for_completion?

    ActiveRecord::Base.transaction do
      payment.mark_complete!
      order.mark_complete!
    end
  rescue ActiveRecord::RecordInvalid, Workflow::TransitionHalted
    payment.make_refund = true
    payment.mark_failed!
  end

  private def valid_order_for_completion?
    OrderValidator.new(order).validate
    return if order.errors.present?

    order.total_amount == payment.amount && order.payment?
  end
end
