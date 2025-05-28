FactoryBot.define do
  factory :meal do
    name { FFaker::FoodPL.unique.food }
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'example.jpg'), 'image/jpg') }
    meal_ingredients_attributes { [ { ingredient_id: create(:ingredient).id, quantity: 1 } ] }
  end
end
