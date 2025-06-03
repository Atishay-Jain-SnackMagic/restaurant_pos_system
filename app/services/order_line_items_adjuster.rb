class OrderLineItemsAdjuster
  attr_accessor :order, :line_items_adjusted

  def initialize(order)
    @order = order
  end

  def adjust_line_items
    return unless inventory_insufficient_for_line_items? || all_meals_active?

    order.line_items.includes(meal: :meal_ingredients).reverse_chronological_order.each do |item|
      if item.meal.is_active? && (max_possible = calculate_max_possible(item)).positive?
        adjust_quantity(item, max_possible)
        deduct_ingredients(item)
      else
        self.line_items_adjusted = true
        item.skip_update_order_amount = true
        item.destroy
      end
    end
  end

  def inventory_insufficient_for_line_items?
    order
      .line_items
      .left_joins(meal: { meal_ingredients: :inventory_locations })
      .where(inventory_locations: { location_id: [ order.location_id, nil ] })
      .group(meal_ingredients: :ingredient_id, inventory_locations: :id)
      .having('SUM(line_items.quantity * meal_ingredients.quantity) > COALESCE(inventory_locations.quantity, 0)')
      .any?
  end

  private def running_inventory
    @running_inventory ||= InventoryLocation.where(location_id: order.location_id).index_by(&:ingredient_id).transform_values(&:quantity)
  end

  private def calculate_max_possible(item)
    item.meal_ingredients.map { |mi| (running_inventory[mi.ingredient_id] || 0) / mi.quantity }.min
  end

  private def adjust_quantity(item, max_possible)
    return if item.quantity <= max_possible

    item.update_column(:quantity, max_possible)
    self.line_items_adjusted = true
  end

  private def deduct_ingredients(item)
    item.meal_ingredients.each do |mi|
      running_inventory[mi.ingredient_id] -= item.quantity * mi.quantity
    end
  end

  private def all_meals_active?
    order.meals.where(is_active: false).exists?
  end
end
