class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :location, null: false, foreign_key: true
      t.datetime :pickup_time
      t.string :mobile_number
      t.integer :fulfilment_status
      t.decimal :total_amount, precision: 7, scale: 2
      t.integer :state, default: 0
      t.datetime :completed_at
      t.datetime :cancelled_at

      t.timestamps
    end
  end
end
