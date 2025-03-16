class ChangeUsersGroupToOptional < ActiveRecord::Migration[7.1]
  def change
    change_column_null :users, :group_id, true
  end
end
