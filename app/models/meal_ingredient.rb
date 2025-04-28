class MealIngredient < ApplicationRecord
  belongs_to :meal
  belongs_to :ingredient

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0, allow_blank: true }
  validates :ingredient_id, uniqueness: { scope: :meal_id, message: :must_be_unique }

  def price
    ingredient.unit_price * quantity
  end
end
