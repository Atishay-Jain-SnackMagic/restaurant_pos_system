class MealsController < ApplicationController
  before_action :set_location

  def index
    meals_scope = Meal.presentable_at_location(@location)
    @meals = MealSearchService.new(meals_scope, filtering_params).process
  end

  private def set_location
    @location = Location.find_by_id(params[:location_id]) || current_user&.default_location || Location.default_location
    current_user&.default_location = @location
    current_user.update_column(:default_location_id, @location&.id) if current_user&.default_location_changed?
    params[:location_id] = @location&.id
  end

  def filtering_params
    params[:q]&.permit(:veg, :non_veg)
  end
end
