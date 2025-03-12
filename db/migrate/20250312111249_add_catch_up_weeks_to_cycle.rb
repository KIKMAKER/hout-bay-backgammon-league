class AddCatchUpWeeksToCycle < ActiveRecord::Migration[7.1]
  def change
    add_column :cycles, :catch_up_weeks, :integer
  end
end
