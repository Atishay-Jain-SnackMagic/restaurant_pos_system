class User < ApplicationRecord
  belongs_to :default_location, class_name: "Location"
  has_secure_password
  include EmailAddressVerification
  has_email_address_verification

  before_validation :set_default_location, on: :create

  validates :name, :email, presence: true
  validates :email, uniqueness: { case_sensitive: false, message: I18n.t('models.user.already_registered') }, format: { with: URI::MailTo::EMAIL_REGEXP, message: I18n.t('models.user.email_invalid') }, allow_blank: true

  private def set_default_location
    self.default_location = Location.default_location
  end
end
