class Ingredient < ApplicationRecord
  has_many :inventory_locations, dependent: :destroy
  has_many :meal_ingredients, dependent: :restrict_with_error
  has_many :meals, through: :meal_ingredients

  validates :name, :unit_price, presence: true
  validates :name, uniqueness: { case_sensitive: false }, allow_blank: true
  validates :unit_price, numericality: { greater_than_or_equal_to: 0.01 }
end
