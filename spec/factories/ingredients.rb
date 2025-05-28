FactoryBot.define do
  factory :ingredient do
    name { FFaker::Food.unique.ingredient }
    unit_price { 1 }
    is_vegetarian { true }
  end
end
