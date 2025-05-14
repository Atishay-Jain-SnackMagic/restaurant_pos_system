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
    broadcast_meal_stock_updates
  end

  private def broadcast_meal_stock_updates
    used_ingredient_ids = line_items.joins(meal: :ingredients).pluck(ingredients: :id).uniq
    affected_meals_ids = Meal.joins(:ingredients).where(ingredients: { id: used_ingredient_ids }).distinct.pluck(:id)
    affected_meals = Meal.where(id: affected_meals_ids).available_at_location(location_id).reject(&:in_stock?)

    affected_meals.each do |meal|
      Turbo::StreamsChannel.broadcast_replace_to(
        "meals:location:#{location_id}",
        target: "meal_#{meal.id}_location_#{location_id}_cart_control",
        partial: "meals/cart_control",
        locals: { meal: meal, location_id: location_id }
      )
    end
  end
end
