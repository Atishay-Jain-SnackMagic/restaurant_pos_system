class Payment < ApplicationRecord
  belongs_to :order

  enum :status, { pending: 0, succeeded: 1, failed: 2, refund_initiated: 3, refund_processed: 4 }

  before_create :create_payment_intent

  def create_payment_intent
    payment_intent = Stripe::PaymentIntent.create({
      amount: order.total_amount_cents,
      currency: 'usd',
      automatic_payment_methods: { enabled: true }
    })
    self.stripe_id = payment_intent.id
    self.client_secret = payment_intent.client_secret
    self.amount = payment_intent.amount/100.0
  end

  def mark_refund
  end
end
