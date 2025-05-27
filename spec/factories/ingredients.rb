FactoryBot.define do
  factory :ingredient do
    sequence(:name) { |n| "Ingredient #{n}" }
    unit_price { 1 }
    is_vegetarian { true }
  end
end
