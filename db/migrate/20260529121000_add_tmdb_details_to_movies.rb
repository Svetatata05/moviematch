class AddTmdbDetailsToMovies < ActiveRecord::Migration[8.0]
  def change
    add_column :movies, :media_type, :string, null: false, default: "movie"
    add_column :movies, :original_title, :string
    add_column :movies, :original_language, :string
    add_column :movies, :tagline, :string
    add_column :movies, :status, :string
    add_column :movies, :budget, :bigint
    add_column :movies, :revenue, :bigint
    add_column :movies, :tmdb_backdrop_path, :string
    add_column :movies, :trailer_key, :string
    add_column :movies, :content_rating, :string

    add_index :movies, [:media_type, :tmdb_id]
    add_index :movies, :media_type
  end
end
