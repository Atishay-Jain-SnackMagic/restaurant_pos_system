class AddUniqueCodeToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :number, :string
    add_index :orders, :number, unique: true
  end
end
