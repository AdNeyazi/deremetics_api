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

ActiveRecord::Schema[8.1].define(version: 2026_03_16_120000) do
# Could not dump table "analytics_events" because of following ArgumentError
#   wrong number of arguments (given 2, expected 1)


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

# Could not dump table "diagnostic_consultations" because of following ArgumentError
#   wrong number of arguments (given 2, expected 1)


  create_table "faqs", id: :string, force: :cascade do |t|
    t.text "answer", default: "", null: false
    t.integer "order", default: 0, null: false
    t.string "question", null: false
  end

# Could not dump table "packages" because of following ArgumentError
#   wrong number of arguments (given 2, expected 1)


# Could not dump table "products" because of following ArgumentError
#   wrong number of arguments (given 2, expected 1)


  create_table "secure_files", id: :string, force: :cascade do |t|
    t.string "content_type", null: false
    t.datetime "created_at", null: false
    t.string "ext", null: false
    t.string "original_name", null: false
    t.string "path", null: false
    t.integer "size", default: 0, null: false
  end

# Could not dump table "site_contents" because of following ArgumentError
#   wrong number of arguments (given 2, expected 1)


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
