class ChangeStatusTypeInPayments < ActiveRecord::Migration[8.0]
  def change
    reversible do |dir|
      dir.up   { change_column :payments, :status, :string, default: 'pending' }
      dir.down do
        change_column_default :payments, :status, from: 'pending', to: nil
        change_column :orders, :status, :integer, using: 'state::integer', default: 0
      end
    end
  end
end
