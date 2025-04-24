module Admin
  class InventoryLocationsController < ApplicationController
    before_action :load_location
    before_action :load_inventory_location, only: [ :show, :edit, :update ]

    def index
      @inventory_locations = @location.inventory_locations
    end

    def show
      @inventory_units = @inventory_location.inventory_units.order(created_at: :desc)
    end

    def new
      @inventory_location = @location.inventory_locations.build
    end

    def create
      @inventory_location = @location.inventory_locations.build(inventory_location_params)
      if @inventory_location.save
        redirect_to admin_location_inventory_locations_path, notice: t('controllers.admin.inventory_locations.create.success')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @inventory_unit = @inventory_location.inventory_units.build
    end

    def update
      if @inventory_location.update(inventory_location_params)
        flash[:notice] = t('controllers.admin.inventory_locations.update.success')
        redirect_to admin_location_inventory_locations_path
      else
        @inventory_location.reload
        render :edit, status: :unprocessable_entity
      end
    end

    private def inventory_location_params
      params.expect(inventory_location: [ :ingredient_id, inventory_units_attributes: [ [ :quantity, :comment ] ] ])
    end

    private def load_inventory_location
      @inventory_location = @location.inventory_locations.find_by(id: params[:id])
      unless @inventory_location
        flash[:error] = t('controllers.admin.inventory_locations.load_inventory_location.failure')
        redirect_to admin_location_inventory_locations_path
      end
    end

    private def load_location
      @location = Location.find_by_id(params[:location_id])
      unless @location
        flash[:error] = t('controllers.admin.inventory_locations.load_location.failure')
        redirect_back_or_to admin_locations_path
      end
    end
  end
end
