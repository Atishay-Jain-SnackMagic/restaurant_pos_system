class CreateRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :ratings do |t|
      t.belongs_to :line_item, null: false, foreign_key: true, index: { unique: :true }
      t.integer :rating

      t.timestamps
    end
  end
end
