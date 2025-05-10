class Payment < ApplicationRecord
  include Workflow

  belongs_to :order

  attr_accessor :make_refund

  enum :status, { pending: 0, complete: 1, failed: 2, refund_initiated: 3, refund_processed: 4 }

  before_create :create_payment_intent

  workflow do
    state :pending do
      event :mark_complete, transitions_to: :complete
      event :mark_failed, transitions_to: :failed
    end

    state :complete do
      event :refund_initiated, transitions_to: :refund_initiated
    end

    state :failed do
      event :make_payment_refund, transitions_to: :refund_initiated
    end

    state :refund_initiated do
      event :mark_refund_completed, transitions_to: :refund_processed
    end

    state :refund_processed

    after_transition do |from, to|
      case [ from, to ]
      when [ :pending, :failed ]
        after_mark_failed
      when [ :failed, :refund_initiated ]
        after_make_payment_refund
      end
    end
  end

  private def load_workflow_state
    status
  end

  private def persist_workflow_state(new_value)
    self.status = new_value
    save!
  end

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

  private def mark_complete
    update!(completed_at: Time.current)
  end

  private def mark_refund_completed
    update!(refunded_at: Time.current)
  end

  private def after_mark_failed
    make_payment_refund! if make_refund
  end

  private def after_make_payment_refund
    Stripe::Refund.create(payment_intent: stripe_id)
    mark_refund_completed!
  end
end
