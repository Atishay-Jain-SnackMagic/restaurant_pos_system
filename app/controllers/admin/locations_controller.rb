class Admin::LocationsController < Admin::ApplicationController
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
      redirect_to admin_locations_path, notice: 'Updated successfully'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def index
    @locations = Location.all.includes(:address).order(:id)
  end

  def show
  end

  def destroy
    if @location.destroy
      redirect_to admin_locations_path, notice: 'Location deleted successfully'
    else
      redirect_to admin_locations_path, notice: 'Location could not be deleted'
    end
  end

  private def location_params
    params.expect(location: [ :name, :opening_time, :closing_time, :is_default, address_attributes: [ :address, :city, :state, :country, :pincode ] ])
  end

  private def load_location
    @location = Location.find_by(id: params[:id])
    redirect_to admin_locations_path, notice: "Location not found" unless @location
  end
end
