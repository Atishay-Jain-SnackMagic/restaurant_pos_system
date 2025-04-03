class CreateJoinTableIngredientMeal < ActiveRecord::Migration[8.0]
  def change
    create_join_table :ingredients, :meals, id: false, primary_key: [ :ingredient_id, :meal_id ] do |t|
      t.integer :quantity
      # t.index [:ingredient_id, :meal_id]
      # t.index [:meal_id, :ingredient_id]
    end
  end
end
