require 'rails_helper'

RSpec.describe OrderLineItemsAdjuster, type: :service do
  let(:inventory_quantity) { 10 }
  let(:required_quantity) { 2 }
  let(:item_quantity) { 3 }

  let!(:order) { create(:order) }
  let!(:ingredient) { create(:ingredient) }
  let!(:inventory_location) { create(:inventory_location, location: order.location, ingredient: ingredient, quantity: inventory_quantity) }
  let!(:meal) { create(:meal, is_active: true, meal_ingredients_attributes: [ { ingredient: ingredient, quantity: required_quantity } ]) }
  let!(:line_item) { order.line_items.create(meal: meal) }

  before { line_item.update_columns(quantity: item_quantity) }

  subject(:adjuster) { described_class.new(order) }

  describe '#adjust_line_items' do
    context 'when inventory is sufficient' do
      it 'should not change line item quantity or delete it' do
        expect { adjuster.adjust_line_items }.not_to change { line_item.reload.quantity }
        expect(order.line_items.reload).to include(line_item)
        expect(line_item.reload.quantity).to eq(item_quantity)
        expect(adjuster.line_items_adjusted).to be_falsey
      end
    end

    context 'when inventory is partially sufficient' do
      let(:inventory_quantity) { 4 }

      it 'should adjust line item quantity to max possible' do
        adjuster.adjust_line_items
        expect(line_item.reload.quantity).to eq(inventory_quantity/required_quantity)
        expect(adjuster.line_items_adjusted).to be_truthy
      end
    end

    context 'when inventory is completely insufficient' do
      before { inventory_location.update_columns(quantity: 0) }

      it 'should delete the line item' do
        expect { adjuster.adjust_line_items }.to change(LineItem, :count).by(-1)
        expect(order.line_items.reload).to be_empty
        expect(adjuster.line_items_adjusted).to be_truthy
      end
    end

    context 'when meal is inactive' do
      before { meal.update!(is_active: false) }

      it 'should delete the line item regardless of inventory' do
        expect { adjuster.adjust_line_items }.to change(LineItem, :count).by(-1)
        expect(order.line_items.reload).to be_empty
        expect(adjuster.line_items_adjusted).to be_truthy
      end
    end
  end

  describe '#inventory_insufficient_for_line_items?' do
    context 'when inventory is insufficient' do
      let(:inventory_quantity) { 4 }

      it 'should return true ' do
        expect(adjuster.inventory_insufficient_for_line_items?).to be_truthy
      end
    end

    context 'when inventory is sufficient' do
      it 'should return false' do
        expect(adjuster.inventory_insufficient_for_line_items?).to be_falsey
      end
    end
  end
end
