class OrdersController < ApplicationController
  before_action :ensure_currently_logged_in
  before_action :load_order_from_unique_code, only: [ :show, :mark_order_cancelled ]
  before_action :ensure_order_not_cart_order, only: :show
  before_action :ensure_order_completed, only: :mark_order_cancelled

  def index
    @orders = current_user.orders.not_cart.includes(location: :address).order(completed_at: :desc)
  end

  def show
  end

  def view_cart
    current_cart.line_items.includes(meal: [ :ingredients, { image_attachment: :blob } ])
    @cart = current_cart
  end

  def mark_order_cancelled
    if OrderCancelService.new(@order).process
      flash[:notice] = t('controllers.orders.mark_order_cancelled.success')
    else
      flash[:error] = t('controllers.orders.mark_order_cancelled.failure', error: @order.errors.full_messages.join(', '))
    end
    redirect_back_or_to orders_path
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

  private def ensure_order_completed
    return if @order.complete?

    flash[:error] = t('controllers.orders.ensure_order_completed.failure')
    redirect_back_or_to orders_path
  end
end
