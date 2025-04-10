class EmailAddressVerificationsController < ApplicationController
  before_action :load_user, :ensure_user_not_verified

  def show
    @user.verify
    redirect_to_login_with_notice(t('controllers.email_address_verifications.verify.success'))
  end

  private def ensure_user_not_verified
    redirect_to_login_with_notice(t('controllers.email_address_verifications.verify.already_verified')) if @user.verified_at?
  end

  private def load_user
    @user = User.find_by_email_address_verification_token(params[:token])
    redirect_to_login_with_notice(t('controllers.email_address_verifications.verify.failure')) unless @user
  end
end
