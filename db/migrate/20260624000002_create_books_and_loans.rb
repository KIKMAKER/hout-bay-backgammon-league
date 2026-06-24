class CreateBooksAndLoans < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :author, null: false

      t.timestamps
    end

    create_table :loans do |t|
      t.references :book, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :loaned_at, null: false
      t.datetime :returned_at
      t.references :loaned_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    # Prevent a book from being loaned twice at the same time
    add_index :loans, :book_id,
              unique: true,
              where: "returned_at IS NULL",
              name: "index_loans_on_book_id_active"
  end
end
