class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.string :address
      t.string :city
      t.string :state
      t.string :country
      t.integer :pincode
      t.belongs_to :addressable, polymorphic: true

      t.timestamps
    end
  end
end
