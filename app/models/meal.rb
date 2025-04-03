class Meal < ApplicationRecord
  has_many :meal_ingredients
  has_many :ingredients, through: :meal_ingredients
end
