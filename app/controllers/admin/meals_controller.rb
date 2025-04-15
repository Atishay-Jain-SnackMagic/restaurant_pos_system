class Admin::MealsController < Admin::ApplicationController
  before_action :load_meal, only: [ :show, :update, :destroy, :edit ]

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

  def index
    @meals = Meal.with_attached_image.includes(:ingredients).all.order(:name)
  end

  def show
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
      redirect_to admin_meals_path, notice: t('controllers.admin.meals.destroy.success')
    else
      redirect_to admin_meals_path, notice: t('controllers.admin.meals.destroy.failure')
    end
  end

  private def load_meal
    @meal = Meal.with_attached_image.includes(meal_ingredients: :ingredient).find_by(id: params[:id])
    redirect_to admin_meals_path, notice: t('controllers.admin.meals.load_meal.failure') unless @meal
  end

  private def meal_params
    params.expect(meal: [ :name, :image, :is_active, meal_ingredients_attributes: [ [ :id, :ingredient_id, :quantity ] ] ])
  end
end
