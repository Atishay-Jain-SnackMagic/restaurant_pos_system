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

    ActiveRecord::Base.transaction do
      raise ActiveRecord::RecordInvalid unless valid_order_for_completion?

      payment.mark_complete!
      order.mark_complete!
    end
  rescue
    payment.make_refund = true
    payment.mark_failed!
  end

  private def valid_order_for_completion?
    order.valid? && !order.price_changed? && order.total_amount == payment.amount && order.meals.all?(&:is_active?) && order.current_state == :payment
  end
end
