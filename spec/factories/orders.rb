FactoryBot.define do
  factory :order do
    association :user, factory: :user
    association :location, factory: :location
  end
end
