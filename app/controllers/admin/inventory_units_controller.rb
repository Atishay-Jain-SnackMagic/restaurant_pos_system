module Admin
  class InventoryUnitsController < ApplicationController
    before_action :load_inventory_location

    def new
      @inventory_unit = InventoryUnit.new(trackable: @inventory_location)
    end

    def create
      @inventory_unit = InventoryUnit.new(inventory_unit_params.merge(trackable: @inventory_location, ingredient_id: @inventory_location.ingredient_id))
      if @inventory_unit.save
        redirect_to admin_inventory_locations_path(location_id: @inventory_location.location_id), notice: t('controllers.admin.inventory_units.create.success')
      else
        @inventory_location.reload
        render :new, status: :unprocessable_entity
      end
    end

    private def load_inventory_location
      @inventory_location = InventoryLocation.find_by_id(params[:inventory_location_id])
      unless @inventory_location
        flash[:error] = t('controllers.admin.inventory_units.load.failure')
        redirect_to admin_inventory_locations_path
      end
    end

    private def inventory_unit_params
      params.expect(inventory_unit: [ :change, :comment ])
    end
  end
end
