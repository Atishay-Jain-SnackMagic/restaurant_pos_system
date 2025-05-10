class OrdersController < ApplicationController
  before_action :ensure_current_user
  before_action :load_order, only: :show

  def cart
    @order = current_order
    @order.cart! unless @order.cart?
    recalculate_and_adjust_order
    flash.now[:error] = t('controllers.orders.line_items_adjusted') if @order_updator.order_modified?
  end

  def index
    @orders = current_user.orders.completed.includes(location: :address).order(pickup_time: :desc)
  end

  def show
  end

  private def load_order
    return if @order = current_user.orders.completed.find_by(number: params[:number])

    flash[:error] = t('controllers.orders.order.invalid')
    redirect_to meals_path
  end
end
