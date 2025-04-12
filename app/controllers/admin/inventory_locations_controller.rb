class Admin::InventoryLocationsController < Admin::ApplicationController
  before_action :load_inventory_location, only: :destroy
  def new
    @inventory_location = InventoryLocation.new
  end

  def index
    @inventories = InventoryLocation.includes(:ingredient).where(location_id: params[:location_id])
  end

  def create
    @inventory_location = InventoryLocation.new(inventory_location_params)
    if @inventory_location.save
      redirect_to admin_inventory_locations_path(location_id: @inventory_location.location_id), notice: t('controllers.admin.inventory_locations.create.success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    if @inventory_location.destroy
      redirect_to admin_inventory_locations_path(location_id: @inventory_location.location_id), notice: t('controllers.admin.inventory_locations.destroy.success')
    else
      redirect_to admin_inventory_locations_path(location_id: @inventory_location.location_id), notice: t('controllers.admin.inventory_locations.destroy.failure')
    end
  end

  private def inventory_location_params
    params.expect(inventory_location: [ :ingredient_id, :location_id, :quantity ])
  end

  private def load_inventory_location
    @inventory_location = InventoryLocation.find_by(id: params[:id])
    redirect_to admin_inventory_locations_path, notice: t('controllers.admin.inventory_units.load.failure') unless @inventory_location
  end
end
