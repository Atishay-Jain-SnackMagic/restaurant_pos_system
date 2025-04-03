class CreateIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :ingredients do |t|
      t.string :name, index: { unique: true }
      t.decimal :unit_price
      t.boolean :extra_allowed
      t.boolean :is_vegetarian

      t.timestamps
    end
  end
end
