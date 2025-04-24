class CreateInventoryUnits < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_units do |t|
      t.belongs_to :inventory_location, null: false, foreign_key: true
      t.integer :quantity
      t.string :comment

      t.timestamps
    end
  end
end
