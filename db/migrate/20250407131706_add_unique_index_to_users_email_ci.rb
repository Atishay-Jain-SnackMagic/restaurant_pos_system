class AddUniqueIndexToUsersEmailCi < ActiveRecord::Migration[8.0]
  def change
    add_index :users, "LOWER(email)", unique: true
  end
end
