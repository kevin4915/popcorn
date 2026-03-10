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

ActiveRecord::Schema[8.1].define(version: 2026_03_09_153348) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "historics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "movie_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["movie_id"], name: "index_historics_on_movie_id"
    t.index ["user_id"], name: "index_historics_on_user_id"
  end

  create_table "movies", force: :cascade do |t|
    t.text "actors"
    t.string "category"
    t.datetime "created_at", null: false
    t.string "director"
    t.integer "duration"
    t.string "platform"
    t.string "poster_url"
    t.decimal "rating"
    t.text "synopsis"
    t.string "title"
    t.string "trailer"
    t.datetime "updated_at", null: false
    t.integer "year"
  end

  create_table "platforms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.text "comment"
    t.datetime "created_at", null: false
    t.bigint "movie_id", null: false
    t.decimal "rating"
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_reviews_on_movie_id"
  end

  create_table "user_platforms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "platform_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["platform_id"], name: "index_user_platforms_on_platform_id"
    t.index ["user_id"], name: "index_user_platforms_on_user_id"
  end

  create_table "user_reviews", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "review_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["review_id"], name: "index_user_reviews_on_review_id"
    t.index ["user_id"], name: "index_user_reviews_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "AmazonPrime"
    t.boolean "CanalPlus"
    t.boolean "DisneyPlus"
    t.boolean "HBO"
    t.boolean "Netflix"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "historics", "movies"
  add_foreign_key "historics", "users"
  add_foreign_key "reviews", "movies"
  add_foreign_key "user_platforms", "platforms"
  add_foreign_key "user_platforms", "users"
  add_foreign_key "user_reviews", "reviews"
  add_foreign_key "user_reviews", "users"
end
