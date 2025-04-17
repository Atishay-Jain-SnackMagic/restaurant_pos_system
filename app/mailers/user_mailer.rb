class UserMailer < ApplicationMailer
  def verify_email(user)
    @user = user
    mail(to: user.email)
  end
end
