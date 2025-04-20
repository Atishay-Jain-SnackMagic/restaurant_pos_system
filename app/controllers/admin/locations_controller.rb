module Admin
  class LocationsController < ApplicationController
    before_action :load_location, only: [ :show, :edit, :update, :destroy ]

    def new
      @location = Location.new
      @location.build_address
    end

    def create
      @location = Location.new(location_params)

      if @location.save
        redirect_to admin_locations_path, notice: t('controllers.admin.locations.save.success')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @location.update(location_params)
        redirect_to admin_locations_path, notice: t('controllers.admin.locations.update.success')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def index
      @locations = Location.all.includes(:address).reverse_chronological_order
    end

    def show
    end

    def destroy
      if @location.destroy
        redirect_to admin_locations_path, notice: t('controllers.admin.locations.destroy.success')
      else
        flash[:error] = @location.errors.full_messages.join(', ')
        redirect_to admin_locations_path
      end
    end

    private def location_params
      params.expect(location: [ :name, :opening_time, :closing_time, :is_default, address_attributes: [ :address, :city, :state, :country, :pincode ] ])
    end

    private def load_location
      @location = Location.find_by(id: params[:id])
      redirect_to admin_locations_path, notice: t('controllers.admin.locations.location.not_found') unless @location
    end
  end
end
