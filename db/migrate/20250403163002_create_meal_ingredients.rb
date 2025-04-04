class CreateMealIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :meal_ingredients do |t|
      t.belongs_to :ingredient, null: false, foreign_key: true
      t.belongs_to :meal, null: false, foreign_key: true
      t.integer :quantity

      t.index [ :ingredient_id, :meal_id ], unique: true
      t.timestamps
    end
  end
end
