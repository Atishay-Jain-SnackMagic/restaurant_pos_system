class CreateMeals < ActiveRecord::Migration[8.0]
  def change
    create_table :meals do |t|
      t.string :name, index: { unique: true }
      t.boolean :is_active

      t.timestamps
    end
  end
end
