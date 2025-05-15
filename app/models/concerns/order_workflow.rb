module OrderWorkflow
  extend ActiveSupport::Concern

  included do
    include WorkflowActiverecord

    workflow_column :state

    workflow do
      state :cart do
        event :mark_checkout, transitions_to: :checkout
      end

      state :checkout do
        event :mark_cart, transitions_to: :cart
        event :mark_payment, transitions_to: :payment
      end

      state :payment do
        event :mark_complete, transitions_to: :complete
        event :mark_cart, transitions_to: :cart
        event :mark_checkout, transitions_to: :checkout
      end

      state :complete do
        event :mark_cancelled, transitions_to: :cancelled
      end

      state :cancelled
    end
  end

  def mark_complete
    transaction do
      update_columns(fulfilment_status: :received, completed_at: Time.current)
      create_inventory_units
    end
  rescue ActiveRecord::RecordInvalid
    halt!
  end

  private def create_inventory_units
    line_items.includes(meal_ingredients: { inventory_locations: [ :ingredient, :location ] }).each do |item|
      item.meal_ingredients.each do |mi|
        item.inventory_units.create!(
          inventory_location: mi.inventory_locations.detect { |inv| inv.location_id == location_id },
          quantity: -item.quantity * mi.quantity
        )
      end
    end
  end

  def on_complete_entry(old_state, event)
    OrderCompletionMailWorker.perform_async(id)
  end

  def mark_cancelled
    transaction do
      release_inventory
      process_refund_payment
    end
  rescue ActiveRecord::RecordInvalid, Workflow::TransitionHalted
    halt!
  end

  def on_cancelled_entry(old_state, event)
    update_columns(cancelled_at: Time.current)
  end

  private def release_inventory
    inventory_units.each(&:revert!)
  end

  private def process_refund_payment
    payment = payments.with_complete_state.first
    payment.mark_refund_initiated!
  end
end
