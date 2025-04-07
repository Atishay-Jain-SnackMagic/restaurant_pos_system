class EmailAddressVerificationsController < ApplicationController
  before_action :set_and_check_valid_user, :ensure_user_not_verified
  
  def show
    @user.verify
    redirect_to_login_with_notice(t('controllers._address_verification.verify.success'))
  end

  def ensure_user_not_verified
    redirect_to_login_with_notice(t('controllers._address_verification.verify.already_verified')) if @user.verified_at?
  end

  private def set_and_check_valid_user
    @user = User.find_by_email_address_verification_token(params[:token])
    redirect_to_login_with_notice(t('controllers.email_address_verification.verify.failure')) unless @user
  end
end
