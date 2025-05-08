class Order < ApplicationRecord
  include Tokenable

  belongs_to :user
  belongs_to :location
  has_many :line_items, dependent: :destroy

  acts_as_tokenable column: :number, prefix: 'O', length: 10

  enum :fulfilment_status, { received: 0, ready: 1, picked_up: 2 }
  enum :state, { cart: 0, complete: 1, cancelled: 2 }

  before_create :generate_token

  def clear_cart
    line_items.destroy_all
  end

  def update_total_amount
    cost = line_items.sum(&:cost)
    update_column(:total_amount, cost) if cost != total_amount
  end
end
