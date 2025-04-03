class Ingredient < ApplicationRecord
  has_many :inventory_locations
  has_many :meal_ingredients
  has_many :meals, through: :meal_ingredients
end
