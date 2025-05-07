module AdminDashboardHelper
  ROUTES = {
    'Locations' => { path: :admin_locations_path, desc: 'Manage all restaurant locations' },
    'Ingredients' => { path: :admin_ingredients_path, desc: 'Track and manage ingredients' },
    'Meals' => { path: :admin_meals_path, desc: 'Create and update meals served' }
  }.freeze

  def quick_routes
    ROUTES.transform_values { |config| { path: public_send(config[:path]), desc: config[:desc] } }
  end
end
