class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :round, null: false, foreign_key: true
      t.datetime :paid_at, null: false
      t.references :marked_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :payments, [:user_id, :round_id], unique: true
  end
end
