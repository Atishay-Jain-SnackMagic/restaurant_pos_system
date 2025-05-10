class PaymentRefund
  include Sidekiq::Job

  def perform(stripe_id)
    payment = Payment.refund_initiated.find_by(stripe_id: stripe_id)
    return unless payment

    Stripe::Refund.create(payment_intent: stripe_id)
    payment.mark_refund_completed!
  end
end
