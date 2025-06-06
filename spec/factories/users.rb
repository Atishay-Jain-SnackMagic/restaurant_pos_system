FactoryBot.define do
  factory :user do
    name { FFaker::Name.unique.name }
    email { FFaker::Internet.unique.email }
    password { 'Abc@12345' }
    is_admin { false }
    association :default_location, factory: :location
  end
end
