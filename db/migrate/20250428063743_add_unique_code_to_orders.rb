class AddUniqueCodeToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :unique_code, :string
    add_index :orders, :unique_code, unique: true
  end
end
