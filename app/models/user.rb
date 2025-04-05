class User < ApplicationRecord
  belongs_to :default_location, class_name: "Location"
  has_secure_password

  before_validation :set_default_location, on: :create

  validates :name, presence: true
  validates :email, presence: true, email: { allow_blank: true }, uniqueness: { message: "is already registered", allow_blank: true }

  private def set_default_location
    self.default_location = Location.default_location unless is_admin
  end
end
