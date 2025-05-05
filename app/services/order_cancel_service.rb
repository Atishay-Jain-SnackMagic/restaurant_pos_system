class OrderCancelService
  attr_reader :order

  def initialize(order)
    @order = order
  end

  def process
    return unless order

    begin
      ActiveRecord::Base.transaction do
        order.mark_cancelled!
        process_line_items!
        process_refund_payment!
      end
      true
    rescue ActiveRecord::RecordInvalid
      false
    end
  end

  private def process_line_items!
    order.line_items.includes(:inventory_units).each do |item|
      # units = item.inventory_units.to_a
      # units.each do |unit|
      #   item.inventory_units.build(inventory_location_id: unit.inventory_location_id, quantity: unit.quantity.abs)
      # end
      item.inventory_units.pluck(:inventory_location_id, :quantity).each do |inventory_location_id, quantity|
        item.inventory_units.create!(inventory_location_id: inventory_location_id, quantity: quantity.abs)
      end
    end
  end

  private def process_refund_payment!
    payment = order.payments.succeeded.first
    payment.update!(status: :refund_initiated)
    Stripe::Refund.create(payment_intent: payment.stripe_id)
    payment.update!(status: :refund_processed)
  end
end
