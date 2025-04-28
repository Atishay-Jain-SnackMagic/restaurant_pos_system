class MealSearchService
  ALLOWABLE_FILTERS = [ :veg, :non_veg ].freeze

  def initialize(scope, params)
    @scope = scope
    @params = params
  end

  def process
    return @scope unless @params.present?

    @params.each do |filter, value|
      next unless ALLOWABLE_FILTERS.include?(filter.to_sym)

      @scope = @scope.public_send(filter)
    end

    @scope
  end
end
