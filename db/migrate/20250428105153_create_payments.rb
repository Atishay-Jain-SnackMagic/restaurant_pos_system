class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.string :stripe_id
      t.string :client_secret
      t.belongs_to :order, null: false, foreign_key: true
      t.integer :status, default: 0
      t.decimal :amount, precision: 7, scale: 2

      t.timestamps
    end
  end
end
