class User < ApplicationRecord
  PASSWORD_REGEXP = %r{\A(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}\z}

  belongs_to :default_location, class_name: "Location"
  has_many :orders, dependent: :destroy
  has_many :payments, through: :orders
  has_secure_password
  generates_token_for(:email_verification, expires_in: MAX_TIME_FOR_TOKEN_CONFIRMATION)
  generates_token_for(:remember_me, expires_in: MAX_DURATION_FOR_REMEMBER_ME_TOKEN)

  generates_token_for(:password_reset, expires_in: MAX_TIME_FOR_TOKEN_CONFIRMATION) do
    password_salt&.last(10)
  end

  before_validation :set_default_location, on: :create
  before_create :set_verified_at, if: :is_admin?
  after_commit :send_verification_mail, on: :create, unless: :is_admin?

  validates :name, :email, presence: true
  validates :email, uniqueness: { case_sensitive: false, message: I18n.t('models.user.already_registered') }, format: { with: URI::MailTo::EMAIL_REGEXP, message: I18n.t('models.user.email_invalid') }, allow_blank: true
  validates :password, format: { with: PASSWORD_REGEXP, allow_nil: true, message: :invalid_password_format }

  def self.find_by_lower_email(email)
    find_by("LOWER(email) = ?", email&.downcase)
  end

  def verify
    update(verified_at: Time.current)
  end

  def send_verification_mail
    UserMailer.verify_email(self).deliver_later
  end

  private def set_default_location
    self.default_location = Location.default_location
  end

  private def set_verified_at
    self.verified_at = Time.current
  end
end
