class CreateCycles < ActiveRecord::Migration[7.1]
  def change
    create_table :cycles do |t|
      t.date :start_date
      t.date :end_date
      t.integer :weeks
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
