class Location < ApplicationRecord
  has_one :address, as: :addressable, dependent: :destroy
  has_many :inventory_locations
end
