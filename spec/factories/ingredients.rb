FactoryBot.define do
  factory :ingredient do
    name { FFaker::Food.unique.ingredient }
    unit_price { 1 }

    trait :veg do
      is_vegetarian { true }
    end

    trait :non_veg do
      is_vegetarian { false }
    end
  end
end
