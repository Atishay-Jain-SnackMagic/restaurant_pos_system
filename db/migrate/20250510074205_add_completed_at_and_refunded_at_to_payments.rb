class AddCompletedAtAndRefundedAtToPayments < ActiveRecord::Migration[8.0]
  def change
    change_table :payments do |t|
      t.datetime :completed_at
      t.datetime :refunded_at
    end
  end
end
