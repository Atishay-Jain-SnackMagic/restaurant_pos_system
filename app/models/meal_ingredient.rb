class MealIngredient < ApplicationRecord
  belongs_to :meal
  belongs_to :ingredient

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_blank: true }
  validates :ingredient_id, uniqueness: { scope: :meal_id, message: I18n.t('models.meal_ingredient.unique_ingredient.failure') }

  def price
    ingredient.unit_price * quantity
  end
end
