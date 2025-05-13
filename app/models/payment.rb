class Payment < ApplicationRecord
  include PaymentWorkflow

  belongs_to :order

  before_create :create_payment_intent

  def create_payment_intent
    payment_intent = Stripe::PaymentIntent.create({
      amount: order.total_amount_cents,
      currency: DEFAULT_CURRENCY,
      automatic_payment_methods: { enabled: true }
    })
    self.stripe_id = payment_intent.id
    self.client_secret = payment_intent.client_secret
    self.amount = order.total_amount
  end
end
