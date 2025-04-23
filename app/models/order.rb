class Order < ApplicationRecord
  belongs_to :user
  belongs_to :location
  has_many :line_items, dependent: :destroy

  enum :fulfilment_status, { received: 0, ready: 1, picked_up: 2 }
  enum :state, { cart: 0, complete: 1, cancelled: 2 }
end
