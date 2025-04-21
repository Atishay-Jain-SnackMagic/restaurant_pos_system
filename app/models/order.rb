class Order < ApplicationRecord
  belongs_to :user
  belongs_to :location
  has_many :line_items

  enum :status, [ :received, :ready, :picked_up ], scope: false
  enum :state, [ :cart, :complete, :cancelled ]
  validates :pickup_time, current_date: { allow_blank: true }, if: :cart_or_completed?

  private def cart_or_completed?
    cart? || completed?
  end
end
