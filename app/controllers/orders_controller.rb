class OrdersController < ApplicationController
  before_action :ensure_current_user
  before_action :load_order, only: [ :show, :confirmation ]

  def cart
    @order = current_order
    recalculate_and_adjust_order

    begin
      @order.mark_cart! unless @order.cart?
    rescue ActiveRecord::RecordInvalid, Workflow::TransitionHalted
      flash[:error] = t('some_error_occured')
      redirect_back_or_to root_path
    end
  end

  def index
    @orders = current_user.orders.completed.includes(location: :address).order(pickup_time: :desc)
  end

  def show
  end

  def confirmation
  end

  private def load_order
    return if @order = current_user.orders.completed.find_by(number: params[:number])

    flash[:error] = t('controllers.orders.order.invalid')
    redirect_to meals_path
  end
end
