class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :location, null: false, foreign_key: true
      t.datetime :pickup_time
      t.string :mobile_number
      t.integer :status
      t.decimal :total_amount
      t.integer :state
      t.datetime :completed_at
      t.datetime :cancelled_at

      t.timestamps
    end
  end
end
