class ChangeCycleToOptional < ActiveRecord::Migration[7.1]
  def change
    change_column_null :matches, :cycle_id, true
  end
end
