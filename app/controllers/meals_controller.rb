class MealsController < ApplicationController
  after_action :set_location_for_current_user

  def index
    @meals = MealSearchService.new(filtering_params).process
  end

  private def filtering_params
    { location_id: current_location.id }.merge(params[:q]&.permit(:veg, :non_veg) || {})
  end

  private def set_location_for_current_user
    return if current_location == current_user&.default_location

    current_user&.update_column(:default_location_id, current_location&.id)
  end
end
