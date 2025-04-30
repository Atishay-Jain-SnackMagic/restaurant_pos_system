class PaymentsController < ApplicationController
  before_action :ensure_currently_logged_in
  before_action :load_order_from_unique_code, only: :new
  before_action :load_payment_from_intent, only: [ :success, :failure ]

  def new
    @payment = @order.payments.create
  end

  def success
    if PaymentSuccessService.new(@payment).process
      flash[:notice] = t('controllers.payments.success.success')
      redirect_to order_path(id: @payment.order.unique_code)
    else
      flash[:error] = t('contollers.payments.success.failure')
      redirect_to view_cart_path
    end
  end

  def failure
    @payment.update(status: :failed)
    flash[:error] = t('controllers.payments.failure')
    redirect_to view_cart_path
  end

  private def load_order_from_unique_code
    @order = Order.find_by_unique_code(params[:order_id])
    unless @order
      flash[:error] = t('controllers.payments.load_order.failure')
      redirect_back_or_to meals_path
    end
  end

  private def load_payment_from_intent
    @payment = Payment.find_by_stripe_id(params[:payment_intent])
    unless @payment
      flash[:error] = t('controllers.payments.load_payment.failure')
      redirect_to meals_path
    end
  end
end
