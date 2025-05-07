class OrderCheckoutProcessor
  include ActiveModel::Validations

  validate :validate_order

  attr_reader :order

  def initialize(order)
    @order = order
  end

  def process
    ActiveRecord::Base.transaction do
      unless valid?
        order.auto_adjust_line_items
      end
      order.recalculate_totals
    end
  end

  private def validate_order
    errors.add(:base, :insufficient_inventory) if order.inventory_insufficient_for_line_items?
  end
end
