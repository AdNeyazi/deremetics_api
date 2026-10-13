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

ActiveRecord::Schema[8.1].define(version: 2026_09_30_151625) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "ahoy_events", force: :cascade do |t|
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.bigint "user_id"
    t.bigint "visit_id"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "app_version"
    t.string "browser"
    t.string "city"
    t.string "country"
    t.string "device_type"
    t.string "ip"
    t.text "landing_page"
    t.float "latitude"
    t.float "longitude"
    t.string "os"
    t.string "os_version"
    t.string "platform"
    t.text "referrer"
    t.string "referring_domain"
    t.string "region"
    t.datetime "started_at"
    t.text "user_agent"
    t.bigint "user_id"
    t.string "utm_campaign"
    t.string "utm_content"
    t.string "utm_medium"
    t.string "utm_source"
    t.string "utm_term"
    t.string "visit_token"
    t.string "visitor_token"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
    t.index ["visitor_token", "started_at"], name: "index_ahoy_visits_on_visitor_token_and_started_at"
  end

  create_table "analytics_events", id: :string, force: :cascade do |t|
    t.string "device", default: "", null: false
    t.string "event_type", null: false
    t.json "metadata", default: {}, null: false
    t.string "page", default: "/", null: false
    t.string "referrer", default: "", null: false
    t.string "session_id"
    t.datetime "timestamp", precision: nil, null: false
    t.string "user_id"
    t.index ["timestamp"], name: "index_analytics_events_on_timestamp"
  end

  create_table "categories", id: :string, force: :cascade do |t|
    t.text "intro_text", default: "", null: false
    t.string "intro_title", default: "", null: false
    t.string "key", null: false
    t.string "label", null: false
    t.integer "order", default: 0, null: false
  end

  create_table "consultations", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.text "message", default: "", null: false
    t.string "name", null: false
    t.string "phone", null: false
    t.string "tier", default: "", null: false
  end

  create_table "diagnostic_consultations", id: :string, force: :cascade do |t|
    t.text "address", default: "", null: false
    t.text "allergies", default: "", null: false
    t.string "blood_group", default: "", null: false
    t.boolean "consent", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.text "current_routine", default: "", null: false
    t.string "email", default: "", null: false
    t.json "face_photo_file_ids", default: [], null: false
    t.string "full_name", null: false
    t.string "phone", null: false
    t.json "report_file_ids", default: [], null: false
    t.string "status", default: "New", null: false
    t.string "user_id"
  end

  create_table "faqs", id: :string, force: :cascade do |t|
    t.text "answer", default: "", null: false
    t.integer "order", default: 0, null: false
    t.string "question", null: false
  end

  create_table "packages", id: :string, force: :cascade do |t|
    t.text "description", default: "", null: false
    t.json "features", default: [], null: false
    t.string "name", null: false
    t.integer "order", default: 0, null: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.boolean "recommended", default: false, null: false
  end

  create_table "products", id: :string, force: :cascade do |t|
    t.text "description", default: "", null: false
    t.string "image_url", default: "", null: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.string "tag", default: "", null: false
    t.string "tier", null: false
    t.json "variants", default: [], null: false
    t.index ["tier"], name: "index_products_on_tier"
  end

  create_table "secure_files", id: :string, force: :cascade do |t|
    t.string "content_type", null: false
    t.datetime "created_at", null: false
    t.string "ext", null: false
    t.string "original_name", null: false
    t.string "path", null: false
    t.integer "size", default: 0, null: false
  end

  create_table "site_contents", primary_key: "key", id: :string, force: :cascade do |t|
    t.text "feedback_text", default: "", null: false
    t.string "feedback_title", default: "", null: false
    t.string "flagship_sub", default: "", null: false
    t.string "flagship_title", default: "", null: false
    t.string "footer_heading", default: "", null: false
    t.text "footer_text", default: "", null: false
    t.string "hero_sub", default: "", null: false
    t.string "hero_title", default: "", null: false
    t.string "phone", default: "", null: false
    t.json "process", default: [], null: false
    t.text "what_text", default: "", null: false
    t.string "what_title", default: "", null: false
    t.text "why_text", default: "", null: false
    t.string "why_title", default: "", null: false
  end

  create_table "team_members", id: :string, force: :cascade do |t|
    t.text "bio", default: "", null: false
    t.string "image_url", default: "", null: false
    t.string "name", null: false
    t.integer "order", default: 0, null: false
    t.string "role", default: "", null: false
  end

  create_table "users", id: :string, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "role", default: "user", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end
end
