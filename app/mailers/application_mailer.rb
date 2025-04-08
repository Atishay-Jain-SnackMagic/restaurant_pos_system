class ApplicationMailer < ActionMailer::Base
  default from: DEFAULT_MAIL_FROM
  layout "mailer"
end
