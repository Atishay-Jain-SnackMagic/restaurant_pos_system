class User < ApplicationRecord
  belongs_to :default_location, class_name: "Location"
  has_secure_password
  generates_token_for(:email_verification, expires_in: MAX_TIME_FOR_TOKEN_CONFIRMATION)

  before_validation :set_default_location, on: :create
  after_commit :send_verification_mail, on: :create

  validates :name, :email, presence: true
  validates :email, uniqueness: { case_sensitive: false, message: I18n.t('models.user.already_registered') }, format: { with: URI::MailTo::EMAIL_REGEXP, message: I18n.t('models.user.email_invalid') }, allow_blank: true

  def verify
    update(verified_at: Time.current)
  end

  private def set_default_location
    self.default_location = Location.default_location
  end

  def self.find_by_lower_email(email)
    find_by("LOWER(email) = ?", email&.downcase)
  end

  def send_verification_mail
    UserMailer.verify_email(self).deliver_later
  end
end
