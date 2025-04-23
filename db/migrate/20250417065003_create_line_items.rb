class CreateLineItems < ActiveRecord::Migration[8.0]
  def change
    create_table :line_items do |t|
      t.belongs_to :meal, null: false, foreign_key: true
      t.belongs_to :order, null: false, foreign_key: true
      t.integer :quantity, default: 1
      t.decimal :unit_price, precision: 7, scale: 2
      t.index [ :meal_id, :order_id ], unique: true

      t.timestamps
    end
  end
end
