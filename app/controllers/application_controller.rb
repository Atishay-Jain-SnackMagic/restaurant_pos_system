class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :set_default_location, if: :current_user

  private def ensure_not_currently_logged_in
    redirect_to(root_path, notice: t('controllers.application.already_logged_in')) if current_user
  end

  private def current_user
    @current_user ||= User.find_by_id(session[:user_id]) || set_user_from_cookie
  end
  helper_method :current_user

  private def current_location
    @current_location ||= Location.find_by_id(params[:location_id]) || current_user&.default_location || Location.default_location
  end
  helper_method :current_location

  private def set_user_from_cookie
     User.find_by_token_for(:remember_me, cookies.signed[:user_id_token])
  end

  private def set_default_location
    current_user.update_column(:default_location_id, Location.default_location&.id) unless current_user.default_location_id?
  end

  private def current_order
    return unless current_user

    @current_order ||= current_user.orders.incomplete.first || current_user.orders.create(location: current_location)
  end
  helper_method :current_order

  private def ensure_current_user
    return if current_user

    flash[:error] = t('controllers.application.logged_in.failure')
    redirect_to root_path
  end

  private def recalculate_and_adjust_order
    order_updator = OrderUpdator.new(@order)
    order_updator.update
    flash.now[:error] = t('controllers.orders.line_items_adjusted') if order_updator.order_modified?
  end
end
