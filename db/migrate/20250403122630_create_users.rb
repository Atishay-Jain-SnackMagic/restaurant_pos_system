class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email, index: { unique: true }, null: false
      t.string :password_digest
      t.boolean :is_admin
      t.datetime :verified_at
      t.references :default_location, foreign_key: { to_table: :locations }

      t.timestamps
    end
  end
end
