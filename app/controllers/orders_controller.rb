class OrdersController < ApplicationController
  before_action :ensure_currently_logged_in
  before_action :load_order_from_unique_code, only: :show
  before_action :ensure_order_not_cart_order, only: :show

  def index
    @orders = current_user.orders.not_cart.includes(location: :address).order(completed_at: :desc)
  end

  def show
  end

  def cart
    order_updator = OrderUpdator.new(current_order)
    order_updator.update
    flash.now[:error] = t('controllers.orders.line_items_adjusted') if order_updator.order_modified?
  end

  private def load_order_from_unique_code
    @order = Order.find_by_unique_code(params[:id])
    unless @order
      flash[:error] = t('controllers.orders.order.invalid')
      redirect_to meals_path
    end
  end

  private def ensure_order_not_cart_order
    return unless @order.cart?

    flash[:error] = t('controllers.orders.order.invalid')
    redirect_to meals_path
  end
end
