class CreateAudits < ActiveRecord::Migration[8.0]
  def change
    create_table :audits do |t|
      t.belongs_to :auditable, polymorphic: true
      t.string :attribute_name
      t.string :old_value
      t.string :new_value

      t.timestamps
    end
  end
end
