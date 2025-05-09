class Order < ApplicationRecord
  include Tokenable

  MOBILE_NUMBER_REGEXP = /\A\d*\z/

  belongs_to :user
  belongs_to :location
  has_many :line_items, dependent: :destroy, autosave: true
  has_many :payments, dependent: :destroy
  has_many :meals, through: :line_items

  acts_as_tokenable column: :number, prefix: 'O', length: 10

  enum :fulfilment_status, { received: 0, ready: 1, picked_up: 2 }
  enum :state, { cart: 0, complete: 1, cancelled: 2 }

  validates :mobile_number, :pickup_time, presence: true, if: :complete?
  validates :mobile_number, format: { with: MOBILE_NUMBER_REGEXP, message: :invalid_mobile_number, allow_blank: true }, if: :mobile_number_changed?
  validates :pickup_time, current_date: { allow_blank: true }, if: :pickup_time_changed?

  before_create :generate_token
  after_save :ensure_have_max_one_succeeded_payment

  def clear_cart
    line_items.destroy_all
  end

  def update_total_amount
    cost = line_items.sum(&:cost)
    update_column(:total_amount, cost) if cost != total_amount
  end

  def total_amount_cents
    (total_amount * 100).to_i
  end

  private def ensure_have_max_one_succeeded_payment
    if payments.succeeded.count > 1
      errors.add(:payment, :payment_already_completed)
      raise ActiveRecord::RecordInvalid
    end
  end
end
