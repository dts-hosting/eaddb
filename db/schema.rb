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

ActiveRecord::Schema[8.0].define(version: 2025_07_21_214534) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "collections", force: :cascade do |t|
    t.integer "source_id", null: false
    t.string "name", null: false
    t.boolean "require_owner_in_record", default: false
    t.string "identifier", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "records_count", default: 0, null: false
    t.index ["source_id", "identifier"], name: "index_collections_on_source_id_and_identifier", unique: true
    t.index ["source_id", "name"], name: "index_collections_on_source_id_and_name", unique: true
    t.index ["source_id"], name: "index_collections_on_source_id"
  end

  create_table "destinations", force: :cascade do |t|
    t.string "type", null: false
    t.string "name", null: false
    t.string "url"
    t.string "identifier"
    t.string "username"
    t.string "password"
    t.integer "collection_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "message"
    t.string "status", default: "active", null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.index ["collection_id"], name: "index_destinations_on_collection_id"
    t.index ["name", "type"], name: "index_destinations_on_name_and_type", unique: true
  end

  create_table "records", force: :cascade do |t|
    t.integer "collection_id", null: false
    t.string "identifier", null: false
    t.date "creation_date"
    t.datetime "modification_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ead_identifier"
    t.string "owner"
    t.string "status", default: "active", null: false
    t.string "message"
    t.index ["collection_id", "identifier"], name: "index_records_on_collection_id_and_identifier", unique: true
    t.index ["collection_id"], name: "index_records_on_collection_id"
    t.index ["ead_identifier"], name: "index_records_on_ead_identifier"
    t.index ["owner"], name: "index_records_on_owner"
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
    t.integer "total_records_count", default: 0, null: false
    t.boolean "transfer_on_import", default: false, null: false
    t.string "message"
    t.string "status", default: "active", null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.index ["name", "url"], name: "index_sources_on_name_and_url", unique: true
    t.index ["name"], name: "index_sources_on_name"
    t.index ["type"], name: "index_sources_on_type"
  end

  create_table "transfers", force: :cascade do |t|
    t.integer "destination_id", null: false
    t.integer "record_id", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "message"
    t.index ["destination_id", "record_id"], name: "index_transfers_on_destination_id_and_record_id", unique: true
    t.index ["destination_id"], name: "index_transfers_on_destination_id"
    t.index ["record_id"], name: "index_transfers_on_record_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "collections", "sources"
  add_foreign_key "destinations", "collections"
  add_foreign_key "records", "collections"
  add_foreign_key "sessions", "users"
  add_foreign_key "transfers", "destinations"
  add_foreign_key "transfers", "records"
end
