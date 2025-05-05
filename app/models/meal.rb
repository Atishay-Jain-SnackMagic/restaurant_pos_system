class Meal < ApplicationRecord
  include MealFilters

  has_many :meal_ingredients, dependent: :destroy
  has_many :ingredients, through: :meal_ingredients
  has_one_attached :image
  accepts_nested_attributes_for :meal_ingredients, reject_if: :all_blank, allow_destroy: true

  validates :image, presence: true, image: { allow_blank: true }
  validates :name, presence: true, uniqueness: true
  validates :meal_ingredients, presence: true
  validate :ensure_ingredient_uniqueness

  def total_price
    meal_ingredients.sum(&:price)
  end

  def is_veg?
    ingredients.all?(&:is_vegetarian?)
  end

  def ensure_ingredient_uniqueness
    ingredient_ids = meal_ingredients.map(&:ingredient_id).reject(&:blank?)
    errors.add(:ingredients, :must_be_unique) if ingredient_ids.size != ingredient_ids.uniq.size
  end
end
