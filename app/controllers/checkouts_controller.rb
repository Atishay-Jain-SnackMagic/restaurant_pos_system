class CheckoutsController < ApplicationController
  before_action :ensure_currently_logged_in
  before_action :load_order
  before_action :ensure_order_belongs_to_user
  before_action :ensure_order_not_empty

  def new
  end

  def create
    @order.assign_attributes(order_checkout_params)

    if OrderCheckoutValidatorService.new(@order).process && @order.save
      redirect_to new_order_payment_path(order_id: @order.unique_code)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private def load_order
    @order = Order.find_by_unique_code(params[:order_id])
    unless @order
      flash[:error] = t('controllers.checkouts.load_order.failure')
      redirect_to meals_path
    end
  end

  private def ensure_order_belongs_to_user
    unless @order.user == current_user
      flash[:error] = t('controllers.checkouts.order_belongs_to_user.failure')
      redirect_to meals_path
    end
  end

  private def ensure_order_not_empty
    if @order.line_items.empty?
      flash[:error] = t('controllers.checkouts.order_not_empty.failure')
      redirect_to meals_path
    end
  end

  private def order_checkout_params
    params.expect(order: [ :pickup_time, :mobile_number ])
  end
end
