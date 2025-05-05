module Admin
  class PosController < ApplicationController
    before_action :load_location

    def index
      @orders = Order.complete.where(location_id: @location.id).not_picked_up.order(:pickup_time)
    end

    private def load_location
      @location = Location.find_by_id(params[:location_id])
      return if @location

      flash[:error] = 'Location not found'
      redirect_to admin_locations_path
    end
  end
end
