class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  validates :address, :city, :state, :country, :pincode, presence: true
  validates :country, inclusion: { in: [ 'India' ] }

  def complete_address
    [ address, city, state, country, pincode ].join(', ')
  end
end
