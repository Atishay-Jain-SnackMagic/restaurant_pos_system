class LineItem < ApplicationRecord
  belongs_to :meal
  belongs_to :location
  has_many :inventory_units, as: :trackable
end
