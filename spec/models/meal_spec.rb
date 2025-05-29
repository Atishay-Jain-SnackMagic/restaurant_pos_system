require 'rails_helper'
INVENTORY_AVAILABILITY_RATIO = 3

RSpec.describe Meal, type: :model do
  let(:veg_ingredient_one) { create(:ingredient, :veg) }
  let(:veg_ingredient_two) { create(:ingredient, :veg) }
  let(:non_veg_ingredient_one) { create(:ingredient, :non_veg) }
  let(:veg_meal_ingredient_one_attributes) { { ingredient: veg_ingredient_one, quantity: 2 } }
  let(:veg_meal_ingredient_two_attributes) { { ingredient: veg_ingredient_two, quantity: 1 } }
  let(:non_veg_meal_ingredient_one_attributes) { { ingredient: non_veg_ingredient_one, quantity: 2 } }

  let(:meal_with_two_veg_meal_ingredients) { create(:meal, meal_ingredients_attributes: [ veg_meal_ingredient_one_attributes, veg_meal_ingredient_two_attributes ]) }
  let(:meal_with_one_meal_ingredient) { create(:meal, meal_ingredients_attributes: [ veg_meal_ingredient_one_attributes ]) }
  let(:meal_with_duplicate_meal_ingredients) { build(:meal, meal_ingredients_attributes: [ veg_meal_ingredient_one_attributes, veg_meal_ingredient_one_attributes ]) }
  let(:meal_with_blank_meal_ingredient) { build(:meal, meal_ingredients_attributes: [ { ingredient_id: nil, quantity: nil } ]) }
  let(:non_veg_meal) { create(:meal, meal_ingredients_attributes: [ veg_meal_ingredient_one_attributes, non_veg_meal_ingredient_one_attributes ]) }

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

    it 'rejects blank meal_ingredients attributes' do
      expect(meal_with_blank_meal_ingredient).not_to be_valid
      expect(meal_with_blank_meal_ingredient.errors[:meal_ingredients]).to include("can't be blank")
    end

    it 'allows meal_ingredients to be destroyed' do
      meal_ingredient = meal_with_two_veg_meal_ingredients.meal_ingredients.first

      expect { meal_ingredient.destroy }.to change(MealIngredient, :count).by(-1)
      expect(meal_with_two_veg_meal_ingredients.reload).to be_valid
      expect(meal_with_two_veg_meal_ingredients.meal_ingredients).not_to include(meal_ingredient)
    end

    it 'does not allow meal_ingredients to be destroyed if becomes blank' do
      meal_ingredient = meal_with_one_meal_ingredient.meal_ingredients.first

      expect { meal_ingredient.destroy }.not_to change(MealIngredient, :count)
      expect(meal_with_one_meal_ingredient.errors[:meal_ingredients]).to include("can't be blank")
    end
  end

  describe '#ensure_ingredient_uniqueness' do
    it 'adds an error if there are duplicate ingredients' do
      expect(meal_with_duplicate_meal_ingredients).not_to be_valid
      expect(meal_with_duplicate_meal_ingredients.errors[:ingredients]).to include('must be unique')
    end

    it 'does not add an error if all ingredients are unique' do
      expect(meal_with_two_veg_meal_ingredients).to be_valid
    end
  end

  describe '#price' do
    it 'calculates the total price correctly' do
      expected_price = meal_with_two_veg_meal_ingredients.meal_ingredients.sum { |mi| mi.quantity * mi.ingredient.unit_price }

      expect(meal_with_two_veg_meal_ingredients.price).to eq(expected_price)
    end
  end

  describe '#is_veg?' do
    it 'returns true if all ingredients are vegetarian' do
      expect(meal_with_two_veg_meal_ingredients.is_veg?).to be true
    end

    it 'returns false if any ingredient is not vegetarian' do
      expect(non_veg_meal.is_veg?).to be false
    end
  end

  describe '#max_available_quantity_at_location' do
    let!(:location) { create(:location) }

    context 'when inventory available' do
      before do
        meal_with_one_meal_ingredient.meal_ingredients.each do |mi|
          create(:inventory_location, location: location, ingredient_id: mi.ingredient_id, quantity: mi.quantity * INVENTORY_AVAILABILITY_RATIO)
        end
      end

      it 'returns the minimum ratio of inventory quantity to meal ingredient quantity' do
        expect(meal_with_one_meal_ingredient.max_available_quantity_at_location(location)).to eq(INVENTORY_AVAILABILITY_RATIO)
      end
    end

    it 'returns 0 when no matching inventory exists' do
      expect(meal_with_one_meal_ingredient.max_available_quantity_at_location(location)).to eq(0)
    end
  end
end
