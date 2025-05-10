class Order < ApplicationRecord
  include Tokenable
  include Workflow

  MOBILE_NUMBER_REGEXP = /\A(\(\+\d{1,3}\)|\+\d{1,3})\d{10}\z/

  belongs_to :user
  belongs_to :location
  has_many :line_items, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :meals, through: :line_items

  acts_as_tokenable column: :number, prefix: 'O', length: 10

  enum :fulfilment_status, { received: 0, ready: 1, picked_up: 2 }
  enum :state, { cart: 0, checkout: 1, payment: 2, complete: 3, cancelled: 4 }

  validates :mobile_number, :pickup_time, presence: true, if: :current_state_more_than_checkout?
  validates :mobile_number, format: { with: MOBILE_NUMBER_REGEXP, message: :invalid_mobile_number, allow_blank: true }, if: :mobile_number_changed?
  validates :pickup_time, current_date: { allow_blank: true }, if: :pickup_time_changed?

  before_create :generate_token

  scope :incomplete, -> { where(completed_at: nil) }
  scope :completed, -> { where.not(completed_at: nil) }

  workflow do
    state :cart do
      event :checkout, transitions_to: :checkout
    end

    state :checkout do
      event :cart, transitions_to: :cart
      event :mark_payment, transitions_to: :payment
    end

    state :payment do
      event :mark_complete, transitions_to: :complete
      event :cart, transitions_to: :cart
      event :checkout, transitions_to: :checkout
    end

    state :complete do
      event :cancelled, transitions_to: :cancelled
    end
  end

  def load_workflow_state
    state
  end

  def persist_workflow_state(new_value)
    self.state = new_value
    save!
  end

  private def current_state_more_than_checkout?
    current_state > :checkout
  end

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

  def price_changed?
    line_items.includes(meal: :ingredients).any? { |line_item| line_item.meal.total_price != line_item.unit_price }
  end

  private def create_inventory_units
    line_items.includes(meal_ingredients: { inventory_locations: [ :ingredient, :location ] }).each do |item|
      item.meal_ingredients.each do |mi|
        item.inventory_units.create!(
          inventory_location: mi.inventory_locations.detect { |inv| inv.location_id == location_id },
          quantity: -item.quantity * mi.quantity
        )
      end
    end
  end

  private def mark_complete
    transaction do
      update!(fulfilment_status: :received, completed_at: Time.current)
      create_inventory_units
    end
  rescue
    halt
  end
end
