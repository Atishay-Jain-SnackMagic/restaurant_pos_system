class Location < ApplicationRecord
  has_one :address, as: :addressable, dependent: :destroy
  has_many :inventory_locations, dependent: :destroy
  has_many :users_with_default_location, class_name: "User", foreign_key: :default_location_id

  validates :name, :opening_time, :closing_time, :address, presence: true
  validates :name, uniqueness: { case_sensitive: false, allow_blank: true }
  validate :closing_time_greater_than_opening_time
  after_validation :reset_previous_default_location, if: -> { is_default? && Location.default_location != self }
  accepts_nested_attributes_for :address, update_only: true
  before_save :make_location_default, if: -> { Location.count == 0 }
  after_save :one_default_location
  before_destroy :ensure_not_the_only_location
  before_destroy :make_new_default, if: -> { is_default? }
  before_destroy :shift_users_to_default_location

  def self.default_location
    Rails.cache.fetch('location_default', expires_in: 12.hours) do
      find_by(is_default: true)
    end
  end

  private def closing_time_greater_than_opening_time
    errors.add(:closing_time, I18n.t('models.location.validations.closing_time.failure')) if opening_time >= closing_time
  end

  private def make_location_default
    self.is_default = true
  end

  private def reset_previous_default_location
    Location.default_location&.update_column(:is_default, false)
    Rails.cache.delete('location_default')
  end

  private def one_default_location
    default_locations = Location.where(is_default: true)
    p default_locations.size
    if default_locations.size != 1
      errors.add(:base, I18n.t('models.location.only_one_location'))
      raise ActiveRecord::RecordInvalid.new(self)
    end
  end

  private def make_new_default
    reset_previous_default_location
    Location.where.not(id: id).first&.update_column(:is_default, true)
  end

  private def ensure_not_the_only_location
    throw :abort if Location.count == 1
  end

  private def shift_users_to_default_location
    users_with_default_location.update_all(default_location_id: Location.default_location.id)
  end
end
