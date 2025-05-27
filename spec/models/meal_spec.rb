require 'rails_helper'

RSpec.describe Meal, type: :model do
  let(:veg_ingredient_one) { create(:ingredient) }
  let(:veg_ingredient_two) { create(:ingredient) }
  let(:non_veg_ingredient_one) { create(:ingredient, is_vegetarian: false) }

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
      meal = build(:meal, meal_ingredients_attributes: [ { ingredient_id: nil, quantity: nil } ])
      expect(meal.valid?).to be false
      expect(meal.errors[:meal_ingredients]).to include("can't be blank")
    end

    it 'allows meal_ingredients to be destroyed' do
      meal = create(:meal, meal_ingredients_attributes: [
        { ingredient: veg_ingredient_one, quantity: 1 },
        { ingredient: veg_ingredient_two, quantity: 1 }
      ])
      meal_ingredient = meal.meal_ingredients.first
      meal_ingredient.mark_for_destruction
      meal.save

      expect(meal.meal_ingredients).not_to include(meal_ingredient)
    end

    it 'does not allow meal_ingredients to be destroyed if becomes blank' do
      meal = create(:meal, meal_ingredients_attributes: [
        { ingredient: veg_ingredient_one, quantity: 1 }
      ])
      meal.meal_ingredients.first.mark_for_destruction

      expect(meal.valid?).to be false
      expect(meal.errors[:meal_ingredients]).to include("can't be blank")
    end
  end

  describe '#ensure_ingredient_uniqueness' do
    it 'adds an error if there are duplicate ingredients' do
      meal = build(:meal, meal_ingredients_attributes: [
        { ingredient: veg_ingredient_one, quantity: 1 },
        { ingredient: veg_ingredient_one, quantity: 2 }
      ])

      expect(meal.valid?).to be false
      expect(meal.errors[:ingredients]).to include('must be unique')
    end

    it 'does not add an error if all ingredients are unique' do
      meal = build(:meal, meal_ingredients_attributes: [
        { ingredient: veg_ingredient_one, quantity: 1 },
        { ingredient: veg_ingredient_two, quantity: 2 }
      ])

      expect(meal.valid?).to be true
    end
  end

  describe '#price' do
    it 'returns the total price based on ingredient unit_price and quantity' do
      meal = create(:meal, meal_ingredients_attributes: [
        { ingredient: veg_ingredient_one, quantity: 2 },
        { ingredient: veg_ingredient_two, quantity: 1 }
      ])

      expect(meal.price).to eq(2 * veg_ingredient_one.unit_price + 1 * veg_ingredient_two.unit_price)
    end
  end

  describe '#is_veg?' do
    it 'returns true if all ingredients are vegetarian' do
      meal = create(:meal, meal_ingredients_attributes: [
        { ingredient: veg_ingredient_one, quantity: 1 },
        { ingredient: veg_ingredient_two, quantity: 2 }
      ])

      expect(meal.is_veg?).to be true
    end

    it 'returns false if any ingredient is not vegetarian' do
      meal = create(:meal, meal_ingredients_attributes: [
        { ingredient: veg_ingredient_one, quantity: 1 },
        { ingredient: non_veg_ingredient_one, quantity: 2 }
      ])

      expect(meal.is_veg?).to be false
    end
  end

  describe '#max_available_quantity_at_location' do
    let(:location) { create(:location) }
    let(:meal) { create(:meal, meal_ingredients_attributes: [ ingredient: veg_ingredient_one, quantity: 2 ]) }

    it 'returns the minimum ratio of inventory quantity to meal ingredient quantity' do
      create(:inventory_location, location: location, ingredient: veg_ingredient_one, quantity: 6)

      expect(meal.max_available_quantity_at_location(location)).to eq(3)
    end

    it 'returns 0 when no matching inventory exists' do
      expect(meal.max_available_quantity_at_location(create(:location))).to eq(0)
    end
  end
end
