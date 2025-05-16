module Admin
  class OrdersController < ApplicationController
    before_action :load_location
    before_action :load_order

    def show
    end

    def cancel
      @order.mark_cancelled!
    rescue ActiveRecord::RecordInvalid, Workflow::TransitionHalted
      flash[:error] = t('controllers.admin.orders.cancel.failure')
    else
      flash[:notice] = t('controllers.admin.orders.cancel.success')
    ensure
      redirect_back_or_to admin_location_order_path(@order.location_id, @order)
    end

    def ready
      @order.ready!
    rescue ActiveRecord::RecordInvalid
      flash[:error] = t('controllers.admin.orders.ready.failure', error: @order.errors.full_messages.join(', '))
    ensure
      redirect_back_or_to admin_location_pos_path(@order.location)
    end

    def picked_up
      @order.picked_up!
    rescue ActiveRecord::RecordInvalid
      flash[:error] = t('controllers.admin.orders.picked_up.failure', error: @order.errors.full_messages.join(', '))
    ensure
      redirect_back_or_to admin_location_pos_path(@order.location)
    end

    private def load_order
      orders = @location.orders.with_complete_state
      if action_name == 'ready'
        @order = orders.received.find_by(number: params[:number])
      elsif action_name == 'picked_up'
        @order = orders.ready.find_by(number: params[:number])
      elsif action_name.in? [ 'show', 'cancel' ]
        @order = orders.includes(line_items: :meal).find_by(number: params[:number])
      end
      return if @order

      flash[:error] = t('controllers.admin.orders.load_order.failure')
      redirect_back_or_to admin_location_pos_path(@location)
    end

    private def load_location
      return if @location = Location.find_by(id: params[:location_id])

      flash[:error] = t('controllers.admin.orders.location_invalid')
      redirect_to admin_locations_path
    end
  end
end
