class PaymentSuccessService
  attr_reader :payment, :order, :location

  def initialize(payment)
    @payment = payment
    @order = payment&.order
    @location = order&.location
  end

  def process
    return unless valid_payment_and_order?

    payment.update(status: :succeeded)

    unless valid_order_for_completion? && complete_order_and_save
      refund_payment
      return false
    end

    true
  end

  private def valid_payment_and_order?
    payment.present? && order.present?
  end

  private def valid_order_for_completion?
    order.valid? && order.total_cost == payment.amount && order.meals.all?(&:is_active?)
  end

  private def complete_order_and_save
    order.assign_attributes(
      total_amount: payment.amount,
      state: :complete,
      fulfilment_status: :received,
      completed_at: Time.current
    )
    update_line_items
    order.save
  end

  private def update_line_items
    order.line_items = order.line_items.includes(meal: { meal_ingredients: :inventory_locations }).each do |item|
      item.unit_price = item.meal.total_price

      item.meal_ingredients.each do |mi|
        item.inventory_units.build(
          inventory_location: mi.inventory_for(location),
          quantity: -item.quantity * mi.quantity
        )
      end
    end
  end

  private def refund_payment
    payment.update(status: :refund_initiated)
    Stripe::Refund.create(payment_intent: payment.stripe_id)
    payment.update(status: :refund_processed)
  end
end
