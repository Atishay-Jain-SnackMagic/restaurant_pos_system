class InventoryUnit < ApplicationRecord
  belongs_to :trackable, polymorphic: true, autosave: true
  belongs_to :ingredient, autosave: true

  validates :change, numericality: { only_integer: true, other_than: 0 }

  before_validation :add_change_in_inventory_location

  private def add_change_in_inventory_location
    if trackable_type == 'InventoryLocation'
      trackable.quantity += change
    end
  end
end
