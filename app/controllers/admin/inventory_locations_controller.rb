module Admin
  class InventoryLocationsController < ApplicationController
    before_action :load_inventory_location, only: :destroy

    def index
      @inventory_locations = InventoryLocation.includes(:ingredient).where(location_id: params[:location_id])
    end

    def new
      @inventory_location = InventoryLocation.new
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
        flash[:notice] = t('controllers.admin.inventory_locations.destroy.success')
      else
        flash[:error] = t('controllers.admin.inventory_locations.destroy.failure').concat(' ', @inventory_location.errors.full_messages.join(', '))
      end
      redirect_to admin_inventory_locations_path(location_id: @inventory_location.location_id)
    end

    private def inventory_location_params
      params.expect(inventory_location: [ :ingredient_id, :location_id, :quantity ])
    end

    private def load_inventory_location
      @inventory_location = InventoryLocation.find_by_id(params[:id])
      unless @inventory_location
        flash[:error] = t('controllers.admin.inventory_units.load.failure')
        redirect_to admin_inventory_locations_path
      end
    end
  end
end
