class InventoryUnit < ApplicationRecord
  belongs_to :inventory_location
  belongs_to :line_item, optional: true
  has_one :ingredient, through: :inventory_location

  validates :quantity, numericality: { only_integer: true, other_than: 0 }

  before_create :add_change_in_inventory_location

  private def add_change_in_inventory_location
    inventory_location.quantity += quantity
    throw :abort unless inventory_location.save
  end

  def revert!
    unit = self.dup
    unit.quantity *= -1
    unit.save!
  end
end
