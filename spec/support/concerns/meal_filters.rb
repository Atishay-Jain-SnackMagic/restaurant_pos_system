require 'spec_helper'

shared_examples_for :meal_filters do
  let(:model) { described_class }
  let(:veg_ingredient) { create(:ingredient, :veg) }
  let(:non_veg_ingredient) { create(:ingredient, :non_veg) }
  let(:veg_meal_ingredient_attributes) { { ingredient: veg_ingredient, quantity: 1 } }
  let(:non_veg_meal_ingredient_attributes) { { ingredient: non_veg_ingredient, quantity: 1 } }
  let(:location) { create(:location) }

  let!(:veg_meal) { create(:meal, is_active: true, meal_ingredients_attributes: [ veg_meal_ingredient_attributes ]) }
  let!(:non_veg_meal) { create(:meal, is_active: true, meal_ingredients_attributes: [ non_veg_meal_ingredient_attributes ]) }
  let!(:mixed_meal) { create(:meal, is_active: true, meal_ingredients_attributes: [ veg_meal_ingredient_attributes, non_veg_meal_ingredient_attributes ]) }
  let!(:inactive_meal) { create(:meal, is_active: false, meal_ingredients_attributes: [ veg_meal_ingredient_attributes ]) }

  describe '.active_meals' do
    it 'returns the active meals only' do
      expect(model.active_meals).to contain_exactly(veg_meal, non_veg_meal, mixed_meal)
    end
  end

  describe 'available_at_location' do
    before { create(:inventory_location, ingredient: veg_ingredient, location: location, quantity: 1) }

    it 'returns only the meals available at the location based on inventory' do
      expect(model.available_at_location(location.id)).to contain_exactly(veg_meal)
      expect(model.available_at_location(location.id)).not_to include(non_veg_meal, mixed_meal)
    end
  end

  describe '.veg' do
    it 'returns only vegetarian meals' do
      expect(model.veg).to contain_exactly(veg_meal, inactive_meal)
    end
  end

  describe '.non_veg' do
    it 'returns meals with at least one non-vegetarian ingredient' do
      expect(model.non_veg).to contain_exactly(non_veg_meal, mixed_meal)
    end
  end
end
