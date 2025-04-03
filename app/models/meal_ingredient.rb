class MealIngredient < ApplicationRecord
  belongs_to :meal
  belongs_to :ingredient

  self.primary_key = [ :meal_id, :ingredient_id ]
end
