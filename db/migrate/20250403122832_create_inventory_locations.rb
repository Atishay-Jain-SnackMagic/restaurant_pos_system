class CreateInventoryLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_locations do |t|
      t.belongs_to :location, null: false, foreign_key: true
      t.belongs_to :ingredient, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
