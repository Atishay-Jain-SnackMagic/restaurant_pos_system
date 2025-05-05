class OrdersController < ApplicationController
  before_action :ensure_currently_logged_in
  before_action :load_order_from_unique_code, only: :show
  before_action :ensure_order_not_cart_order, only: :show

  def index
    @orders = current_user.orders.not_cart.includes(location: :address).order(completed_at: :desc)
  end

  def show
  end

  def view_cart
    current_cart.line_items.includes(meal: [ :ingredients, { image_attachment: :blob } ])
    @cart = current_cart
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
