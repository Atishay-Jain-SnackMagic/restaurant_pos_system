class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private def ensure_not_currently_logged_in
    redirect_to(root_path, notice: t("controllers.application.already_logged_in")) if current_user
  end

  private def current_user
    @current_user ||= User.find_by_id(session[:user_id]) || set_user_from_cookie
  end
  helper_method :current_user

  private def set_user_from_cookie
     User.find_by_token_for(:remember_me, cookies.signed[:user_id_token])
  end
end
