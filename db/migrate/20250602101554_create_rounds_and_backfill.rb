
class CreateRoundsAndBackfill < ActiveRecord::Migration[7.1]
  def up
    # --- schema ----------------------------------------------------
    create_table :rounds do |t|
      t.date :start_date, null: false
      t.date :end_date,   null: false
      t.timestamps
    end

    add_reference :cycles, :round, foreign_key: true, index: true

    # --- data back-fill -------------------------------------------
    say_with_time "Creating rounds and assigning cycles" do
      Cycle.distinct
           .pluck(:start_date, :end_date)
           .each do |start_date, end_date|
             Round.create!(start_date: start_date, end_date: end_date)
           end

      Cycle.find_each do |c|
        round = Round.find_by!(start_date: c.start_date,
                               end_date:   c.end_date)
        c.update_column(:round_id, round.id) # skip validations/callbacks
      end
    end
  end

  def down
    remove_reference :cycles, :round, index: true, foreign_key: true
    drop_table :rounds
  end
end
