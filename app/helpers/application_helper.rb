module ApplicationHelper
  def current_order_has_line_items?
    current_order&.line_items&.present?
  end
end
