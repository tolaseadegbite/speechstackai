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

ActiveRecord::Schema[8.0].define(version: 2026_01_09_165947) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
  end

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

  create_table "events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "action", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.text "comment"
    t.integer "rating"
    t.integer "feedback_type"
    t.integer "service"
    t.bigint "user_id", null: false
    t.bigint "generated_audio_clip_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["generated_audio_clip_id"], name: "index_feedbacks_on_generated_audio_clip_id"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "generated_audio_clips", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "text"
    t.string "original_voice_s3_key"
    t.string "s3_key"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "voice_id"
    t.string "type"
    t.index ["user_id", "created_at"], name: "index_generated_audio_clips_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_generated_audio_clips_on_user_id"
    t.index ["voice_id"], name: "index_generated_audio_clips_on_voice_id"
  end

  create_table "language_voices", force: :cascade do |t|
    t.bigint "language_id", null: false
    t.bigint "voice_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["language_id"], name: "index_language_voices_on_language_id"
    t.index ["voice_id"], name: "index_language_voices_on_voice_id"
  end

  create_table "languages", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_languages_on_name", unique: true
    t.index ["user_id"], name: "index_languages_on_user_id"
  end

  create_table "recovery_codes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "code", null: false
    t.boolean "used", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_recovery_codes_on_user_id"
  end

  create_table "security_keys", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "external_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_security_keys_on_external_id", unique: true
    t.index ["user_id"], name: "index_security_keys_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "sudo_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sign_in_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sign_in_tokens_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "verified", default: false, null: false
    t.boolean "otp_required_for_sign_in", default: false, null: false
    t.string "otp_secret", null: false
    t.string "webauthn_id", null: false
    t.string "provider"
    t.string "uid"
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "credits", default: 100, null: false
    t.boolean "admin", default: false
    t.string "first_name"
    t.string "last_name"
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "voices", force: :cascade do |t|
    t.string "name", null: false
    t.string "gender", null: false
    t.string "description"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "s3_key"
    t.string "gradient_start"
    t.string "gradient_end"
    t.integer "visibility", default: 0
    t.index ["user_id"], name: "index_voices_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "events", "users"
  add_foreign_key "feedbacks", "generated_audio_clips"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "generated_audio_clips", "users"
  add_foreign_key "generated_audio_clips", "voices"
  add_foreign_key "language_voices", "languages"
  add_foreign_key "language_voices", "voices"
  add_foreign_key "languages", "users"
  add_foreign_key "recovery_codes", "users"
  add_foreign_key "security_keys", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "sign_in_tokens", "users"
  add_foreign_key "users", "accounts"
  add_foreign_key "voices", "users"
end
