class Meal < ApplicationRecord
  include MealFilters

  attr_accessor :marked_for_destroy

  has_many :meal_ingredients, dependent: :destroy
  has_many :ingredients, through: :meal_ingredients
  has_one_attached :image
  accepts_nested_attributes_for :meal_ingredients, reject_if: :all_blank, allow_destroy: true

  validates :image, presence: true, image: { allow_blank: true }
  validates :name, presence: true, uniqueness: true
  validates :meal_ingredients, presence: true
  validate :ensure_ingredient_uniqueness

  before_destroy :set_marked_for_destroy, prepend: true

  def max_available_quantity_at_location(location)
    meal_ingredients
      .left_joins(:inventory_locations)
      .where(inventory_locations: { location_id: [ location.id, nil ] })
      .select('MIN(COALESCE(inventory_locations.quantity, 0) / meal_ingredients.quantity) as max_quantity')
      .take.max_quantity || 0
  end

  def price
    meal_ingredients
      .joins(:ingredient)
      .sum('ingredients.unit_price * meal_ingredients.quantity')
  end

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

  private def set_marked_for_destroy
    self.marked_for_destroy = true
  end
end
