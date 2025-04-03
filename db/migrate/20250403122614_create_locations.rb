class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.string :name, index: { unique: true }
      t.time :opening_time
      t.time :closing_time

      t.timestamps
    end
  end
end
