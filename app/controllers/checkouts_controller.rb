class CheckoutsController < ApplicationController
  before_action :ensure_current_user
  before_action :load_order
  before_action :ensure_order_cart_order, only: :new
  before_action :ensure_order_belongs_to_user
  before_action :ensure_order_not_empty

  def new
    order_updator = OrderUpdator.new(@order)
    order_updator.update
    flash.now[:error] = t('controllers.orders.line_items_adjusted') if order_updator.order_modified?
  end

  def create
    OrderCheckoutService.new(@order, params).process

    if @order.errors.empty?
      redirect_to new_order_payment_path(order_id: @order.number)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private def load_order
    return if @order = Order.find_by_number(params[:order_id])

    flash[:error] = t('controllers.checkouts.load_order.failure')
    redirect_to meals_path
  end

  private def ensure_order_cart_order
    return if @order.cart?

    flash[:error] = t('controllers.checkouts.ensure_order_cart_order.failure')
    redirect_to meals_path
  end

  private def ensure_order_belongs_to_user
    return if @order.user == current_user

    flash[:error] = t('controllers.checkouts.order_belongs_to_user.failure')
    redirect_to meals_path
  end

  private def ensure_order_not_empty
    return if @order.line_items.any?

    flash[:error] = t('controllers.checkouts.order_not_empty.failure')
    redirect_to meals_path
  end
end
