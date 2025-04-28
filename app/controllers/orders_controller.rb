class OrdersController < ApplicationController
  before_action :ensure_currently_logged_in

  def view_cart
    current_cart.line_items.includes(meal: [ :ingredients, { image_attachment: :blob } ])
    @cart = current_cart
  end
end
