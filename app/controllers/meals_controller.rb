class MealsController < ApplicationController
  before_action :set_location

  def index
    @meals = Meal.presentable_at_location(@location).load
  end

  def veg
    @meals = Meal.presentable_at_location(@location).select(&:is_veg?)
    render :index
  end

  def non_veg
    @meals = Meal.presentable_at_location(@location).reject(&:is_veg?)
    render :index
  end

  private def set_location
    if params[:location_id] && @location = Location.find_by_id(params[:location_id])
      if current_user
        current_user.default_location = @location
        current_user.update_column(:default_location_id, @location&.id) if current_user.default_location_changed?
      end
    else
      if current_user
        @location = current_user.default_location
      else
        @location = Location.default_location
      end
      params[:location_id] = @location.id
    end
  end
end
