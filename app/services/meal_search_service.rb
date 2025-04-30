class MealSearchService
  ALLOWABLE_FILTERS = [ :veg, :non_veg, :location_id ].freeze

  attr_accessor :scope, :params

  def initialize(params)
    @scope = Meal
    @params = params
  end

  def process
    return scope unless params.present?

    process_filters
    scope.with_image.includes(:ingredients).order(:name)
  end

  private def process_filters
    params.each do |filter, value|
      next unless ALLOWABLE_FILTERS.include?(filter.to_sym)

      public_send("apply_#{filter}_filter", value)
    end
  end

  def apply_veg_filter(value)
    self.scope = scope.veg if value.present?
  end

  def apply_non_veg_filter(value)
    self.scope = scope.non_veg if value.present?
  end

  def apply_location_id_filter(value)
    self.scope = scope.available_at_location(value)
  end
end
