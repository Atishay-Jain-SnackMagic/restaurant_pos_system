class InventoryLocation < ApplicationRecord
  belongs_to :location
  belongs_to :ingredient
  has_many :inventory_units, dependent: :destroy
  accepts_nested_attributes_for :inventory_units, reject_if: :all_blank

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_blank: true }
  validates :ingredient, uniqueness: { scope: :location }
end
