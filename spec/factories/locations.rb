FactoryBot.define do
  factory :location do
    name { FFaker::Address.unique.city }
    opening_time { Time.current.change(hour: 10) }
    closing_time { Time.current.change(hour: 20) }
    address_attributes { { address: 'Street 1', city: 'Delhi', state: 'Delhi', country_code: 'IN', pincode: 110001 } }
  end
end
