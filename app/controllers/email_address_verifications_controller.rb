class EmailAddressVerificationsController < ApplicationController
  def show
    user = User.find_by_email_address_verification_token(params[:token])
    if user
      unless user.verified?
        user.verify
        redirect_to_login_with_notice("You have been successfully verified. Please login again")
      else
        redirect_to_login_with_notice("User already verified")
      end
    else
      redirect_to_login_with_notice("Email verification link is invalid or expired. Login again to resend the verification email")
    end
  end
end
