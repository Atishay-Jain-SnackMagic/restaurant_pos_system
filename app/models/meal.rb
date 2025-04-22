class Meal < ApplicationRecord
  has_many :meal_ingredients, dependent: :destroy
  has_many :ingredients, through: :meal_ingredients
  has_one_attached :image

  scope :active_meals, -> { where(is_active: true) }
  scope :with_image, -> { includes(image_attachment: :blob) }
  scope :presentable_at_location, ->(location) { available_at_location(location).with_image.includes(:ingredients).order(:name) }

  def self.available_at_location(location)
    active_meals
      .joins(meal_ingredients: :inventory_locations)
      .where(inventory_locations: { location_id: location.id })
      .group(:id)
      .having('COUNT(meal_ingredients.id) = COUNT(CASE WHEN meal_ingredients.quantity <= inventory_locations.quantity THEN 1 END)')
  end

  def total_price
    meal_ingredients.sum(&:price)
  end

  def is_veg?
    ingredients.all?(&:is_vegetarian?)
  end
end
