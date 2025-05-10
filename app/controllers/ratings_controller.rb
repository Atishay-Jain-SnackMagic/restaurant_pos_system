class RatingsController < ApplicationController
  before_action :ensure_currently_logged_in
  before_action :load_line_item
  before_action :ensure_line_item_not_rated

  def create
    flash[:error] = @line_item.errors.full_messages.join(', ') unless @line_item.create_rating(rating: params[:rating])
    redirect_back_or_to orders_path
  end

  private def load_line_item
    return if @line_item = current_user.line_items.find_by(id: params[:id])
    
    flash[:error] = 'Invalid line item'
    redirect_to root_path
  end

  private def ensure_line_item_not_rated
    return unless @line_item.rating

    flash[:error] = 'Already rated'
    redirect_back_or_to orders_path
  end
end
