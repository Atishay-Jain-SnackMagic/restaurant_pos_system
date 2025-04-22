class ChangeIsActiveDefaultInMeals < ActiveRecord::Migration[8.0]
  def change
    change_column_default :meals, :is_active, from: nil, to: true
  end
end
