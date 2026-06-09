class AddMissingFieldsToMovies < ActiveRecord::Migration[8.0]
  def change
    add_column :movies, :runtime, :integer
    add_column :movies, :release_date, :date
    add_column :movies, :tmdb_poster_path, :string
    add_column :movies, :tmdb_id, :integer
    add_column :movies, :director, :string
  end
end
