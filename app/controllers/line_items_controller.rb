class LineItemsController < ApplicationController
  before_action :ensure_current_user
  before_action :load_line_item, only: [ :update, :destroy ]

  def create
    @line_item = current_order.line_items.build(meal_id: params[:meal_id])
    if @line_item.save
      flash[:notice] = t('controllers.line_items.create.success')
    else
      flash[:error] = t('controllers.line_items.create.failure', error: @line_item.errors.full_messages.join(', '))
    end
    redirect_to meals_path
  end

  def update
    if params[:quantity].to_i == 0
      @line_item.destroy
    elsif @line_item.update(quantity: params[:quantity])
      flash[:success] = t('controllers.line_items.update.success')
    else
      flash[:error] = t('controllers.line_items.update.failure', error: @line_item.errors.full_messages.join(', '))
    end
    redirect_back_or_to meals_path
  end

  def destroy
    if @line_item.destroy
      flash[:notice] = t('controllers.line_items.destroy.success')
    else
      flash[:error] = t('controllers.line_items.destroy.failure', error: @line_item.errors.full_messages)
    end
    redirect_back_or_to meals_path
  end

  private def load_line_item
    return if @line_item = current_order.line_items.find_by(id: params[:id])

    flash[:error] = t('controllers.line_items.load.failure')
    redirect_back_or_to meals_path
  end
end
