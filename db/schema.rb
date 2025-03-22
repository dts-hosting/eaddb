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

ActiveRecord::Schema[8.0].define(version: 2025_03_22_033706) do
  create_table "collections", force: :cascade do |t|
    t.integer "source_id", null: false
    t.string "name", null: false
    t.string "owner"
    t.boolean "require_owner_in_record", default: false
    t.string "identifier", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_id", "name"], name: "index_collections_on_source_id_and_name", unique: true
    t.index ["source_id"], name: "index_collections_on_source_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sources", force: :cascade do |t|
    t.string "name", null: false
    t.string "url", null: false
    t.string "username"
    t.string "password"
    t.string "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "collections_count", default: 0, null: false
    t.index ["name", "url"], name: "index_sources_on_name_and_url", unique: true
    t.index ["name"], name: "index_sources_on_name"
    t.index ["type"], name: "index_sources_on_type"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "collections", "sources"
  add_foreign_key "sessions", "users"
end
