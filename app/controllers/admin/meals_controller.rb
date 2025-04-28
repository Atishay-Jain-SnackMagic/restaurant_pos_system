module Admin
  class MealsController < ApplicationController
    before_action :load_meal, only: [ :show, :edit, :update, :destroy ]

    def index
      @meals = Meal.with_image.includes(:ingredients).order(:name)
    end

    def show
    end

    def new
      @meal = Meal.new
    end

    def create
      @meal = Meal.new(meal_params)

      if @meal.save
        redirect_to admin_meals_path, notice: t('controllers.admin.meals.create.success')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @meal.update(meal_params)
        redirect_to admin_meals_path, notice: t('controllers.admin.meals.update.success')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @meal.destroy
        flash[:notice] = t('controllers.admin.meals.destroy.success')
      else
        flash[:error] = t('controllers.admin.meals.destroy.failure', error: @meal.errors.full_messages.join(', '))
      end
      redirect_to admin_meals_path
    end

    private def load_meal
      @meal = Meal.with_image.includes(meal_ingredients: :ingredient).find_by_id(params[:id])
      unless @meal
        flash[:error] = t('controllers.admin.meals.load_meal.failure')
        redirect_to admin_meals_path
      end
    end

    private def meal_params
      params.expect(meal: [ :name, :image, :is_active, meal_ingredients_attributes: [ [ :id, :ingredient_id, :quantity, :_destroy ] ] ])
    end
  end
end
