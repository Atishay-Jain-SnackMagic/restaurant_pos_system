module PaymentWorkflow
  extend ActiveSupport::Concern

  included do
    include WorkflowActiverecord

    attr_accessor :make_refund

    workflow_column :status

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
        event :mark_refund_completed, transitions_to: :refund_completed
        event :mark_refund_failed, transitions_to: :refund_failed
      end

      state :refund_completed
      state :refund_failed
    end
  end

  private def on_complete_entry(old_state, event)
    update!(completed_at: Time.current)
  end

  private def on_refund_processed_entry(old_state, event)
    update!(refunded_at: Time.current)
  end

  private def on_failed_entry(old_state, event)
    make_payment_refund! if make_refund
  end

  private def on_refund_initiated_entry(old_state, event)
    PaymentRefund.perform_async(stripe_id)
  end
end
