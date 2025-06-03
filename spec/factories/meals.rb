FactoryBot.define do
  factory :meal do
    name { FFaker::FoodPL.unique.food }
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'example.jpg'), 'image/jpg') }
  end
end
