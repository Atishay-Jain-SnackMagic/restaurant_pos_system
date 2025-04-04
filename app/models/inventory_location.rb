class InventoryLocation < ApplicationRecord
  belongs_to :location
  belongs_to :ingredient
end
