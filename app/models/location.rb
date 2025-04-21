class Location < ApplicationRecord
  has_one :address, as: :addressable, dependent: :destroy
  has_many :inventory_locations, dependent: :destroy
  has_many :users_with_default_location, class_name: 'User', foreign_key: :default_location_id, dependent: :nullify

  validates :name, :opening_time, :closing_time, :address, presence: true
  validates :name, uniqueness: { case_sensitive: false, allow_blank: true }
  validate :closing_time_greater_than_opening_time
  validate :ensure_not_unmarking_default_location, on: :update, if: [ :is_default_was, :is_default_changed? ]

  accepts_nested_attributes_for :address, update_only: true

  before_save :unmark_previous_default_location, if: :default_location_changed?
  before_destroy :ensure_not_the_default_location

  scope :reverse_chronological_order, -> { order(created_at: :desc) }

  def self.default_location
    Rails.cache.fetch('location_default', expires_in: 12.hours) do
      find_by_is_default(true)
    end
  end

  private def closing_time_greater_than_opening_time
    errors.add(:closing_time, I18n.t('models.location.validations.closing_time.failure')) if opening_time >= closing_time
  end

  private def unmark_previous_default_location
    self.class.default_location&.update_column(:is_default, false)
    Rails.cache.delete('location_default')
  end

  private def default_location_changed?
    is_default? && self.class.default_location&.id != id
  end

  private def ensure_not_unmarking_default_location
    errors.add(:base, I18n.t('models.location.unmarking_default_location_failure'))
  end

  private def ensure_not_the_default_location
    if is_default?
      errors.add(:base, I18n.t('models.location.default_location_delete_failure'))
      throw :abort
    end
  end
end
