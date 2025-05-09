class PaymentSuccessService
  attr_reader :payment, :order, :location, :is_successfull, :order_updator

  def initialize(payment)
    @payment = payment
    @order = payment&.order
    @location = order&.location
    @order_updator = OrderUpdator.new(order)
  end

  def process
    return unless valid_payment_and_order?

    payment.update_column(:status, :succeeded)

    ActiveRecord::Base.transaction do
      order_updator.update
      raise ActiveRecord::Rollback if order_updator.order_modified? && !valid_order_for_completion?

      create_inventory_units
      update_order
      @is_successfull = true
    end
  rescue
    refund_payment
  end

  private def valid_payment_and_order?
    payment.present? && order.present?
  end

  private def update_order
    order.update(
        state: :complete,
        fulfilment_status: :received,
        completed_at: Time.current
      )
  end

  private def valid_order_for_completion?
    order.valid? && order.total_amount == payment.amount && order.meals.all?(&:is_active?)
  end

  private def create_inventory_units
    order.line_items.includes(meal: { meal_ingredients: :inventory_locations }).each do |item|
      item.meal_ingredients.each do |mi|
        item.inventory_units.create(
          inventory_location: mi.inventory_locations.detect { |inv| inv.location_id == location&.id },
          quantity: -item.quantity * mi.quantity
        )
      end
    end
  end

  private def refund_payment
    payment.update_column(:status, :refund_initiated)
    Stripe::Refund.create(payment_intent: payment.stripe_id)
    payment.update_column(:status, :refund_processed)
  end
end
