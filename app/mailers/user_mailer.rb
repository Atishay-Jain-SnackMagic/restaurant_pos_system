class UserMailer < ApplicationMailer
  default from: "my_restaurant@example.com"

  def verify_email_address(user)
    @user = user
    mail(subject: "Please verify your email", to: user.email)
  end
end
