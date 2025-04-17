class Meal < ApplicationRecord
  has_many :meal_ingredients, dependent: :destroy
  has_many :ingredients, through: :meal_ingredients
  has_one_attached :image
  accepts_nested_attributes_for :meal_ingredients, update_only: true, reject_if: ->(attributes) { attributes['ingredient_id'].blank? && attributes['quantity'].blank? }


  validates :image, presence: true, image: { allow_blank: true }
  validates :name, presence: true, uniqueness: true
  validates :meal_ingredients, presence: true
  validate :unique_ingredients

  def unique_ingredients
    ingredient_ids = meal_ingredients.map(&:ingredient_id).reject(&:blank?)
    errors.add(:ingredients, I18n.t('models.meal.unique_ingredients.failure')) if ingredient_ids.size != ingredient_ids.uniq.size
  end

  def total_price
    meal_ingredients.sum(&:price)
  end

  def is_veg?
    ingredients.all?(&:is_vegetarian)
  end

  scope :active_meals, -> { where(is_active: true) }
  scope :with_image, -> { includes(image_attachment: :blob) }

  def self.available_at_location(location)
    joins(meal_ingredients: :inventory_locations)
      .where(inventory_locations: { location_id: location.id })
      .group(:id)
      .having('COUNT(meal_ingredients.id) = COUNT(CASE WHEN meal_ingredients.quantity <= inventory_locations.quantity THEN 1 END)')
      .active_meals
  end
end
