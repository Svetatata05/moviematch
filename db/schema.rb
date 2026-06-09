# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_06_01_000834) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "movie_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id", "created_at"], name: "index_comments_on_movie_id_and_created_at"
    t.index ["movie_id"], name: "index_comments_on_movie_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "movie_reactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "movie_id", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_movie_reactions_on_movie_id"
    t.index ["user_id", "movie_id"], name: "index_movie_reactions_on_user_id_and_movie_id", unique: true
    t.index ["user_id", "status"], name: "index_movie_reactions_on_user_id_and_status"
    t.index ["user_id"], name: "index_movie_reactions_on_user_id"
  end

  create_table "movies", force: :cascade do |t|
    t.string "title"
    t.float "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "genre"
    t.integer "release_year"
    t.string "poster_url"
    t.text "description"
    t.integer "runtime"
    t.date "release_date"
    t.string "tmdb_poster_path"
    t.integer "tmdb_id"
    t.string "director"
    t.string "media_type", default: "movie", null: false
    t.string "original_title"
    t.string "original_language"
    t.string "tagline"
    t.string "status"
    t.bigint "budget"
    t.bigint "revenue"
    t.string "tmdb_backdrop_path"
    t.string "trailer_key"
    t.string "content_rating"
    t.bigint "user_id"
    t.boolean "manually_added", default: false, null: false
    t.index ["manually_added"], name: "index_movies_on_manually_added"
    t.index ["media_type", "tmdb_id"], name: "index_movies_on_media_type_and_tmdb_id"
    t.index ["media_type"], name: "index_movies_on_media_type"
    t.index ["user_id"], name: "index_movies_on_user_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "movie_id", null: false
    t.integer "score", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_ratings_on_movie_id"
    t.index ["user_id", "movie_id"], name: "index_ratings_on_user_id_and_movie_id", unique: true
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "share_token", null: false
    t.boolean "admin", default: false, null: false
    t.index ["admin"], name: "index_users_on_admin"
    t.index ["share_token"], name: "index_users_on_share_token", unique: true
  end

  create_table "watchlists", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "movie_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_watchlists_on_movie_id"
    t.index ["user_id"], name: "index_watchlists_on_user_id"
  end

  add_foreign_key "comments", "movies"
  add_foreign_key "comments", "users"
  add_foreign_key "movie_reactions", "movies"
  add_foreign_key "movie_reactions", "users"
  add_foreign_key "movies", "users"
  add_foreign_key "ratings", "movies"
  add_foreign_key "ratings", "users"
  add_foreign_key "watchlists", "movies"
  add_foreign_key "watchlists", "users"
end
