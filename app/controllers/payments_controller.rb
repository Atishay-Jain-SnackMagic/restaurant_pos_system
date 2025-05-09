class PaymentsController < ApplicationController
  before_action :ensure_current_user
  before_action :load_order_from_number, only: :new
  before_action :load_payment_from_intent, only: [ :success, :failure ]

  def new
    @payment = @order.payments.create
  end

  def success
    payment_success_service = PaymentSuccessService.new(@payment)
    payment_success_service.process
    if payment_success_service.is_successfull
      flash[:notice] = t('controllers.payments.success.success')
      redirect_to order_path(id: @payment.order.number)
    else
      flash[:error] = t('controllers.payments.success.failure')
      redirect_to cart_path
    end
  end

  def failure
    @payment.update(status: :failed)
    flash[:error] = t('controllers.payments.failure')
    redirect_to cart_path
  end

  private def load_order_from_number
    @order = Order.find_by_number(params[:order_id])
    unless @order
      flash[:error] = t('controllers.payments.load_order.failure')
      redirect_to meals_path
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
