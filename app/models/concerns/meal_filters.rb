module MealFilters
  extend ActiveSupport::Concern

  included do
    scope :active_meals, -> { where(is_active: true) }
    scope :with_image, -> { includes(image_attachment: :blob) }
  end

  class_methods do
    def available_at_location(location_id)
      active_meals
      .left_joins(meal_ingredients: :inventory_locations)
      .where(inventory_locations: { location_id: [ location_id, nil ] })
      .group(:id)
      .having('COUNT(meal_ingredients.id) = COUNT(CASE WHEN inventory_locations.quantity >= meal_ingredients.quantity THEN 1 END)')
    end

    def veg
      joins(meal_ingredients: :ingredient)
        .group(:id)
        .having('COUNT(meal_ingredients.id) = COUNT(CASE WHEN ingredients.is_vegetarian = TRUE THEN 1 END)')
    end

    def non_veg
      joins(meal_ingredients: :ingredient)
        .group(:id)
        .having('COUNT(CASE WHEN ingredients.is_vegetarian = FALSE THEN 1 END) > 0')
    end
  end
end
