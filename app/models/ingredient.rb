class Ingredient < ApplicationRecord
  has_many :inventory_locations, dependent: :destroy
  has_many :meal_ingredients, dependent: :restrict_with_error
  has_many :meals, through: :meal_ingredients
end
