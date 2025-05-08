class OrdersController < ApplicationController
  before_action :ensure_current_user

  def cart
    order_updator = OrderUpdator.new(current_order)
    order_updator.update
    flash.now[:error] = t('controllers.orders.line_items_adjusted') if order_updator.order_modified?
  end
end
