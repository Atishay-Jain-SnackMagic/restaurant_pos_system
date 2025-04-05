class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private def save_user_in_cookie(user, remember_me)
    if remember_me
      cookies.signed[:user_id] = { value: user.id, expires: 30.days.from_now }
    else
      cookies.signed[:user_id] = user.id
    end
  end

  private def ensure_not_currently_logged_in
    redirect_to(root_path, notice: "Already logged in") if cookies.signed[:user_id]
  end
end
