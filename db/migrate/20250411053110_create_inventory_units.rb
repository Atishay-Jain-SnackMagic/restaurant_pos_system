class CreateInventoryUnits < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_units do |t|
      t.belongs_to :trackable, polymorphic: true
      t.belongs_to :ingredient, null: false, foreign_key: true
      t.integer :change
      t.string :comment

      t.timestamps
    end
  end
end
