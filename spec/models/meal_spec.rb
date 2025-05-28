require 'rails_helper'
INVENTORY_AVAILABILITY_RATIO = 3

RSpec.describe Meal, type: :model do
  let(:veg_ingredient_one) { create(:ingredient) }
  let(:veg_ingredient_two) { create(:ingredient) }
  let(:non_veg_ingredient_one) { create(:ingredient, is_vegetarian: false) }
  let(:veg_meal_ingredient_one_attributes) { { ingredient: veg_ingredient_one, quantity: 2 } }
  let(:veg_meal_ingredient_two_attributes) { { ingredient: veg_ingredient_two, quantity: 1 } }
  let(:non_veg_meal_ingredient_one_attributes) { { ingredient: non_veg_ingredient_one, quantity: 2 } }

  before two_veg_meal_ingredients: true do
    @meal = create(:meal, meal_ingredients_attributes: [ veg_meal_ingredient_one_attributes, veg_meal_ingredient_two_attributes ])
  end

  before one_meal_ingredient: true do
    @meal = create(:meal, meal_ingredients_attributes: [ veg_meal_ingredient_one_attributes ])
  end

  before duplicate_meal_ingredients: true do
    @meal = build(:meal, meal_ingredients_attributes: [ veg_meal_ingredient_one_attributes, veg_meal_ingredient_one_attributes ])
  end

  before blank_meal_ingredient: true do
    @meal = build(:meal, meal_ingredients_attributes: [ { ingredient_id: nil, quantity: nil } ])
  end

  before non_veg_meal: true do
    @meal = create(:meal, meal_ingredients_attributes: [ veg_meal_ingredient_one_attributes, non_veg_meal_ingredient_one_attributes ])
  end

  before create_inventory_location: true do
    @meal.meal_ingredients.each do |mi|
      create(:inventory_location, location: location, ingredient_id: mi.ingredient_id, quantity: mi.quantity * INVENTORY_AVAILABILITY_RATIO)
    end
  end

  let(:meal) { @meal }

  describe 'associations' do
    it { should have_many(:meal_ingredients).dependent(:destroy) }
    it { should have_many(:ingredients).through(:meal_ingredients) }
    it { should have_one_attached(:image) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:image) }
    it { should validate_presence_of(:meal_ingredients) }
  end

  describe 'nested attributes' do
    it 'accepts nested attributes for meal_ingredients' do
      should accept_nested_attributes_for(:meal_ingredients)
    end

    it 'rejects blank meal_ingredients attributes', blank_meal_ingredient: true do
      expect(meal).not_to be_valid
      expect(meal.errors[:meal_ingredients]).to include("can't be blank")
    end

    it 'allows meal_ingredients to be destroyed', two_veg_meal_ingredients: true do
      meal_ingredient = meal.meal_ingredients.first
      meal_ingredient.mark_for_destruction
      meal.save

      expect(meal).to be_valid
      expect(meal.meal_ingredients).not_to include(meal_ingredient)
    end

    it 'does not allow meal_ingredients to be destroyed if becomes blank', one_meal_ingredient: true do
      meal.meal_ingredients.first.mark_for_destruction

      expect(meal).not_to be_valid
      expect(meal.errors[:meal_ingredients]).to include("can't be blank")
    end
  end

  describe '#ensure_ingredient_uniqueness' do
    it 'adds an error if there are duplicate ingredients', duplicate_meal_ingredients: true do
      expect(meal).not_to be_valid
      expect(meal.errors[:ingredients]).to include('must be unique')
    end

    it 'does not add an error if all ingredients are unique', two_veg_meal_ingredients: true do
      expect(meal).to be_valid
    end
  end

  describe '#price' do
    it 'calculates the total price correctly', two_veg_meal_ingredients: true do
      expected_price = meal.meal_ingredients.sum { |mi| mi.quantity * mi.ingredient.unit_price }

      expect(meal.price).to eq(expected_price)
    end
  end

  describe '#is_veg?' do
    it 'returns true if all ingredients are vegetarian', two_veg_meal_ingredients: true do
      expect(meal.is_veg?).to be true
    end

    it 'returns false if any ingredient is not vegetarian', non_veg_meal: true do
      expect(meal.is_veg?).to be false
    end
  end

  describe '#max_available_quantity_at_location', one_meal_ingredient: true do
    let!(:location) { create(:location) }

    it 'returns the minimum ratio of inventory quantity to meal ingredient quantity', create_inventory_location: true do
      expect(meal.max_available_quantity_at_location(location)).to eq(INVENTORY_AVAILABILITY_RATIO)
    end

    it 'returns 0 when no matching inventory exists' do
      expect(meal.max_available_quantity_at_location(location)).to eq(0)
    end
  end
end
