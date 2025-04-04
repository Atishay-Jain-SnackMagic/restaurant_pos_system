class CreateIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :ingredients do |t|
      t.string :name, index: { unique: true }
      t.decimal :unit_price, precision: 7, scale: 2
      t.boolean :extra_allowed, default: false
      t.boolean :is_vegetarian, default: true

      t.timestamps
    end
  end
end
