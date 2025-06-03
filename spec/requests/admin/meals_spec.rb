require 'rails_helper'

RSpec.describe 'Admin::Meals', type: :request do
  let!(:ingredient) { create(:ingredient) }

  let(:valid_attributes) { attributes_for(:meal) }
  let(:invalid_attributes) { { name: '', meal_ingredients_attributes: [ { ingredient_id: nil, quantity: nil } ] } }
  let(:meal) { create(:meal) }

  before do
    admin_user = create(:user, is_admin: true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin_user)
  end

  describe 'GET /admin/meals' do
    it 'renders the index' do
      get admin_meals_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /admin/meals/:id' do
    context 'when meal exists' do
      it 'renders the show template' do
        get admin_meal_path(meal)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(meal.name)
      end
    end

    context 'when meal does not exist' do
      it 'redirects to index with flash error' do
        get admin_meal_path('invalid')
        expect(response).to redirect_to(admin_meals_path)
        follow_redirect!
        expect(response.body).to include(I18n.t('controllers.admin.meals.load_meal.failure'))
      end
    end
  end

  describe 'GET /admin/meals/new' do
    it 'renders the new template' do
      get new_admin_meal_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /admin/meals' do
    context 'with valid params' do
      it 'creates a new meal and redirects' do
        expect { post admin_meals_path, params: { meal: valid_attributes } }.to change(Meal, :count).by(1)
        expect(response).to redirect_to(admin_meals_path)
        follow_redirect!
        expect(response.body).to include(I18n.t('controllers.admin.meals.create.success'))
      end
    end

    context 'with invalid params' do
      it 'does not create a meal and renders :new' do
        expect { post admin_meals_path, params: { meal: invalid_attributes } }.not_to change(Meal, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('There were some problems with your submission:')
      end
    end
  end

  describe 'GET /admin/meals/:id/edit' do
    it 'renders the edit template' do
      get edit_admin_meal_path(meal)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /admin/meals/:id' do
    context 'with valid params' do
      it 'updates the meal and redirects' do
        patch admin_meal_path(meal), params: { meal: { name: 'Updated Meal' } }
        expect(response).to redirect_to(admin_meals_path)
        expect(meal.reload.name).to eq('Updated Meal')
      end
    end

    context 'with invalid params' do
      it 'does not update the meal and renders edit' do
        old_name = meal.name
        patch admin_meal_path(meal), params: { meal: { name: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(meal.reload.name).to eq(old_name)
      end
    end
  end

  describe 'DELETE /admin/meals/:id' do
    let!(:meal) { create(:meal) }

    it 'destroys the meal and redirects' do
      expect { delete admin_meal_path(meal) }.to change(Meal, :count).by(-1)
      expect(response).to redirect_to(admin_meals_path)
    end

    it 'shows error message if destroy fails' do
      allow_any_instance_of(Meal).to receive(:destroy).and_return(false)
      allow_any_instance_of(Meal).to receive_message_chain(:errors, :full_messages).and_return([ 'Failed to delete' ])

      delete admin_meal_path(meal)
      expect(response).to redirect_to(admin_meals_path)
      follow_redirect!
      expect(response.body).to include('Failed to delete')
    end
  end
end
