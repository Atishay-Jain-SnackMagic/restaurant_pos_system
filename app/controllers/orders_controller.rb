class OrdersController < ApplicationController
  before_action :ensure_current_user

  def cart
    order_checkout = OrderCheckoutProcessor.new(current_order)
    order_checkout.process
    flash.now[:error] = order_checkout.errors.full_messages.join(', ') if order_checkout.errors.any?
  end
end
