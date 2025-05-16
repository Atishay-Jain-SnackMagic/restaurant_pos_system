module Admin
  class PosController < ApplicationController
    include Pagination

    before_action :load_location

    def index
      @orders = @location.orders.with_complete_state.includes(:user).not_picked_up.order(:pickup_time)
      @orders = @orders.then(&paginate)
    end

    private def load_location
      return if @location = Location.find_by(id: params[:location_id])

      flash[:error] = t('controllers.admin.pos.location_invalid')
      redirect_to admin_locations_path
    end
  end
end
