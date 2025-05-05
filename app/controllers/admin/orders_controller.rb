module Admin
  class OrdersController < ApplicationController
    before_action :load_order
    before_action :ensure_order_received, only: :mark_order_ready
    before_action :ensure_order_ready, only: :mark_order_picked_up

    def mark_order_ready
      unless @order.update(fulfilment_status: :ready)
        flash[:error] = 'Error in marking order ready'
      end
      redirect_back_or_to admin_location_pos_path(@order.location)
    end

    def mark_order_picked_up
      unless @order.update(fulfilment_status: :picked_up)
        flash[:error] = 'Error in marking order picked up'
      end
      redirect_back_or_to admin_location_pos_path(@order.location)
    end

    private def load_order
      @order = Order.find_by_id(params[:order_id])
      return if @order

      flash[:error] = 'Error loading order'
      redirect_to admin_locations_path
    end

    private def ensure_order_ready
      return if @order.ready?

      flash[:error] = 'Order not ready'
      redirect_back_or_to admin_location_pos_path(@order.location)
    end

    private def ensure_order_received
      return if @order.received?

      flash[:error] = 'Order not picked_up'
      redirect_back_or_to admin_location_pos_path(@order.location)
    end
  end
end
