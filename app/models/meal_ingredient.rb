class MealIngredient < ApplicationRecord
  belongs_to :meal
  belongs_to :ingredient
  has_many :inventory_locations, foreign_key: :ingredient_id, primary_key: :ingredient_id

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0, allow_blank: true }
  validates :ingredient_id, uniqueness: { scope: :meal_id, message: :must_be_unique }

  after_destroy :validate_meal

  def price
    ingredient.unit_price * quantity
  end

  private def validate_meal
    return if meal.marked_for_destroy

    raise ActiveRecord::Rollback unless meal.reload.valid?
  end
end
