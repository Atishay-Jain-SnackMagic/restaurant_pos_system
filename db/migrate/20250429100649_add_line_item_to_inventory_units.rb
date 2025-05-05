class AddLineItemToInventoryUnits < ActiveRecord::Migration[8.0]
  def change
    add_reference :inventory_units, :line_item, foreign_key: true
  end
end
