FactoryBot.define do
  factory :meal do
    name { 'Burger' }
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'example.jpg'), 'image/jpg') }
  end
end
