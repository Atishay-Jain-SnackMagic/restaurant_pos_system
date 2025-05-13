class CheckoutsController < ApplicationController
  before_action :ensure_current_user
  before_action :load_order
  before_action :ensure_order_not_empty

  def new
    recalculate_and_adjust_order
    begin
      @order.mark_checkout! unless @order.checkout?
    rescue ActiveRecord::RecordInvalid, Workflow::TransitionHalted
      flash[:error] = t('some_error_occured')
      redirect_back_or_to cart_path
    end
  end

  def create
    OrderCheckoutService.new(@order, params).process

    if @order.errors.empty?
      redirect_to new_order_payment_path(order_number: @order.number)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private def load_order
    return if @order = current_user.orders.incomplete.find_by(number: params[:order_number])

    flash[:error] = t('controllers.checkouts.load_order.failure')
    redirect_to meals_path
  end

  private def ensure_order_not_empty
    return if @order.line_items.any?

    flash[:error] = t('controllers.checkouts.order_not_empty.failure')
    redirect_to meals_path
  end
end
