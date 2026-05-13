class AddFieldsToMovies < ActiveRecord::Migration[8.0]
  def change
    add_column :movies, :genre, :string
    add_column :movies, :release_year, :integer
    add_column :movies, :poster_url, :string
    add_column :movies, :description, :text
  end
end
