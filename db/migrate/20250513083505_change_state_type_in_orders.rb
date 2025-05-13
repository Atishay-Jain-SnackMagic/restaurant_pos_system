class ChangeStateTypeInOrders < ActiveRecord::Migration[8.0]
  def change
    reversible do |dir|
      dir.up   { change_column :orders, :state, :string, default: 'cart' }
      dir.down do
        change_column_default :orders, :state, from: 'cart', to: nil
        change_column :orders, :state, :integer, using: 'state::integer', default: 0
      end
    end
  end
end
