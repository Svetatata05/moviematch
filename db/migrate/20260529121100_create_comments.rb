class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end

    add_index :comments, [:movie_id, :created_at]
  end
end
