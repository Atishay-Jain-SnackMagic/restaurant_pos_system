class PasswordMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail(to: user.email)
  end
end
