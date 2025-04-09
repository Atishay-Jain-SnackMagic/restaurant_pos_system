class Location < ApplicationRecord
  has_one :address, as: :addressable, dependent: :destroy
  has_many :inventory_locations, dependent: :destroy

  validates :name, :opening_time, :closing_time, :address, presence: true
  validates :name, uniqueness: { case_sensitive: false, allow_blank: true }
  accepts_nested_attributes_for :address

  def self.default_location
    Rails.cache.fetch('location_default', expires_in: 12.hours) do
      Location.find_by(is_default: true)
    end
  end
end
