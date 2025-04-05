class Location < ApplicationRecord
  has_one :address, as: :addressable, dependent: :destroy
  has_many :inventory_locations, dependent: :destroy

  def self.default_location
    Location.where(is_default: true).first
  end
end
