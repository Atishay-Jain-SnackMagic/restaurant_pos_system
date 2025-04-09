class User < ApplicationRecord
  belongs_to :default_location, class_name: "Location"
  has_secure_password
  include EmailAddressVerification
  has_email_address_verification
  MAX_TIME_FOR_PASSWORD_RESET_TOKEN = 1.hours
  include UserRememberMeToken
  has_user_remember_me_token

  generates_token_for(:password_reset, expires_in: MAX_TIME_FOR_PASSWORD_RESET_TOKEN) do
    password_salt&.last(10)
  end

  before_validation :set_default_location, on: :create

  validates :name, :email, presence: true
  validates :email, uniqueness: { case_sensitive: false, message: I18n.t('models.user.already_registered') }, format: { with: URI::MailTo::EMAIL_REGEXP, message: I18n.t('models.user.email_invalid') }, allow_blank: true

  def verify
    update(verified_at: Time.now)
  end

  private def set_default_location
    self.default_location = Location.default_location
  end

  def self.find_by_email(email)
    find_by("LOWER(email) = ?", email&.downcase)
  end
end
