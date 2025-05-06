class AddUniqueCodeToOrders < ActiveRecord::Migration[8.0]
  def change
    change_table :orders do |t|
      t.string :number, index: { unique: true }
    end
  end
end
