# db/migrate/XXXXXXXXXXXXXX_make_cycle_id_nullable_in_matches.rb
class MakeCycleIdNullableInMatches < ActiveRecord::Migration[7.1]
  def change
    change_column_null :matches, :cycle_id, true
  end
end
