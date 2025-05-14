class PaymentRefundWorker
  include Sidekiq::Job

  def perform(stripe_id)
    payment = Payment.with_refund_initiated_state.find_by(stripe_id: stripe_id)
    return unless payment

    refund = Stripe::Refund.create(payment_intent: stripe_id)
    raise unless refund.status == 'succeeded'

    payment.mark_refund_completed!
  end
end
