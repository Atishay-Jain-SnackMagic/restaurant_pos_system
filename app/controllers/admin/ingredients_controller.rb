module Admin
  class IngredientsController < ApplicationController
    before_action :load_ingredient, only: [ :edit, :destroy, :update ]

    def index
      @ingredients = Ingredient.all
    end

    def new
      @ingredient = Ingredient.new
    end

    def create
      @ingredient = Ingredient.new(ingredient_params)
      if @ingredient.save
        redirect_to admin_ingredients_path, notice: t('controllers.admin.ingredients.create.success')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @ingredient.update(ingredient_params)
        redirect_to admin_ingredients_path, notice: t('controllers.admin.ingredients.update.success')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @ingredient.destroy
        flash[:notice] = t('controllers.admin.ingredients.destroy.success')
      else
        flash[:error] = @ingredient.errors.full_messages.join(', ')
      end
      redirect_to admin_ingredients_path
    end

    private def load_ingredient
      @ingredient = Ingredient.find_by(id: params[:id])
      redirect_back_or_to admin_ingredients_path, notice: t('controllers.admin.ingredients.load_ingredient.failure') unless @ingredient
    end

    private def ingredient_params
      params.expect(ingredient: [ :name, :unit_price, :extra_allowed, :is_vegetarian ])
    end
  end
end
