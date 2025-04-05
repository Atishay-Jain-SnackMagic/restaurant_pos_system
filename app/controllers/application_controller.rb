class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private def save_user_in_session(user)
    session[:user_id] = user.id
  end

  private def ensure_not_currently_logged_in
    redirect_to(root_path, notice: "Already logged in") if session[:user_id]
  end
end
