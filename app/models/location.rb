class Location < ApplicationRecord
  has_one :address, as: :addressable, dependent: :destroy
  has_many :inventory_locations, dependent: :destroy

  def self.default_location
    Rails.cache.fetch('location_default', expires_in: 12.hours) do
      find_by(is_default: true)
    end
  end
end
