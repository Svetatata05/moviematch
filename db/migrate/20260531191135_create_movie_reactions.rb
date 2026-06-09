class CreateMovieReactions < ActiveRecord::Migration[8.0]
  def change
    create_table :movie_reactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true
      t.string :status, null: false

      t.timestamps
    end

    add_index :movie_reactions, [:user_id, :movie_id], unique: true
    add_index :movie_reactions, [:user_id, :status]
  end
end
