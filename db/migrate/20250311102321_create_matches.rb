class CreateMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :matches do |t|
      t.references :player1, null: false, foreign_key: { to_table: :users }
      t.references :player2, null: false, foreign_key: { to_table: :users }
      t.integer :player1_score
      t.integer :player2_score
      t.references :winner, null: true, foreign_key: { to_table: :users }
      t.datetime :match_date
      t.references :cycle, null: false, foreign_key: true

      t.timestamps
    end
  end
end
