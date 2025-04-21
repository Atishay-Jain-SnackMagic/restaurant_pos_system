class Address < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :addressable, polymorphic: true
  belongs_to :country, foreign_key: :country_code, primary_key: :iso_code

  validates :address, :city, :state, :country_code, :pincode, presence: true
  validates :country_code, inclusion: { in: [ 'IN' ], allow_blank: true }

  def complete_address
    [ address, city, state, country.name, pincode ].join(', ')
  end
end
