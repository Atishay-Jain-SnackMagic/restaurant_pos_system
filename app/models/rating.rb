class Rating < ApplicationRecord
  belongs_to :line_item
  has_one :order, through: :line_item

  validates :rating, presence: true, numericality: { only_integer: true, in: 1..5 }
  validates :line_item_id, uniqueness: true
  validate :ensure_rating_for_a_picked_order, if: :line_item_id?

  private def ensure_rating_for_a_picked_order
    return if order.picked_up?

    errors.add(:order, :should_be_picked)
  end
end
