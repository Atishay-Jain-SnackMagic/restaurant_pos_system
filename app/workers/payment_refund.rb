class PaymentRefund
  include Sidekiq::Job

  def perform(stripe_id)
    payment = Payment.refund_initiated.find_by(stripe_id: stripe_id)
    return unless payment

    refund = Stripe::Refund.create(payment_intent: stripe_id)
    if refund.status == 'succeeded'
      payment.mark_refund_completed!
    else
      payment.mark_refund_failed!
    end
  end
end
