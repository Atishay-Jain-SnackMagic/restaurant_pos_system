class Order < ApplicationRecord
  belongs_to :user
  belongs_to :location
  has_many :line_items, dependent: :destroy

  enum :status, [ :received, :ready, :picked_up ]
  enum :state, [ :cart, :complete, :cancelled ]
end
