class OrdersController < ApplicationController
  before_action :ensure_current_user
  before_action :load_order_from_number, only: :show
  before_action :ensure_order_not_cart_order, only: :show

  def cart
    order_updator = OrderUpdator.new(current_order)
    order_updator.update
    flash.now[:error] = t('controllers.orders.line_items_adjusted') if order_updator.order_modified?
  end

  def index
    @orders = current_user.orders.not_cart.includes(location: :address).order(pickup_time: :desc)
  end

  def show
  end

  private def load_order_from_number
    @order = Order.find_by_number(params[:id])
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
