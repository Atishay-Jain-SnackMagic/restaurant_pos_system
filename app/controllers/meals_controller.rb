class MealsController < ApplicationController
  before_action :clear_cart_on_location_change
  after_action :set_location_for_current_user

  def index
    @meals = MealSearchService.new(filtering_params).process
  end

  private def filtering_params
    { location_id: current_location.id }.merge(params[:q]&.permit(:veg, :non_veg) || {})
  end

  private def clear_cart_on_location_change
    return if !current_order || current_order.location == current_location

    current_order.clear_cart
    flash.now[:notice] = t('controllers.meals.clear_cart.success')
    current_order.update_column(:location_id, current_location&.id)
  end

  private def set_location_for_current_user
    return if current_location == current_user&.default_location

    current_user&.update_column(:default_location_id, current_location&.id)
  end
end
