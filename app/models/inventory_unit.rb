class InventoryUnit < ApplicationRecord
  belongs_to :inventory_location
  has_one :ingredient, through: :inventory_location

  validates :quantity, numericality: { only_integer: true, other_than: 0 }

  before_create :add_change_in_inventory_location

  private def add_change_in_inventory_location
    inventory_location.quantity += quantity
    unless inventory_location.save
      inventory_location.errors.each do |error|
        errors.add(:inventory_location, error.full_message)
      end
      throw :abort
    end
  end
end
