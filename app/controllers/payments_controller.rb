class PaymentsController < ApplicationController
  before_action :ensure_current_user
  before_action :load_order, only: :new
  before_action :load_payment, only: [ :complete, :failure ]

  def new
    @payment = @order.payments.create
  end

  def complete
    payment_manager = PaymentManager.new(@payment)
    payment_manager.process
    if @payment.complete?
      flash[:notice] = t('controllers.payments.success.success')
      redirect_to confirmation_order_path(number: @payment.order.number)
    else
      flash[:error] = t('controllers.payments.success.failure')
      redirect_to cart_path
    end
  end

  def failure
    @payment.mark_failed!
    flash[:error] = t('controllers.payments.failure')
    redirect_to cart_path
  end

  private def load_order
    return if @order = current_user.orders.incomplete.find_by(number: params[:order_number])

    flash[:error] = t('controllers.payments.load_order.failure')
    redirect_to meals_path
  end

  private def load_payment
    return if @payment = current_user.payments.with_pending_state.find_by(stripe_id: params[:payment_intent])

    flash[:error] = t('controllers.payments.load_payment.failure')
    redirect_to meals_path
  end
end
