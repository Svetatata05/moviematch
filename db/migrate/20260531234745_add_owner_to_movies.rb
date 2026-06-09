class AddOwnerToMovies < ActiveRecord::Migration[8.0]
  def change
    add_reference :movies, :user, foreign_key: true
    add_column :movies, :manually_added, :boolean, null: false, default: false
    add_index :movies, :manually_added
  end
end
