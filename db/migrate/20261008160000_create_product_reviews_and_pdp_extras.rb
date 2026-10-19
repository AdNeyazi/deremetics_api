# frozen_string_literal: true

class CreateProductReviewsAndPdpExtras < ActiveRecord::Migration[8.1]
  def change
    create_table "product_reviews", id: :string, force: :cascade do |t|
      t.string "product_id", null: false
      t.string "user_id"
      t.string "author_name", default: "", null: false
      t.integer "rating", null: false
      t.string "title", default: "", null: false
      t.text "body", default: "", null: false
      t.json "photos", default: [], null: false
      t.string "status", default: "pending", null: false
      t.boolean "verified_purchase", default: false, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["product_id"], name: "index_product_reviews_on_product_id"
      t.index ["status"], name: "index_product_reviews_on_status"
      t.index ["user_id"], name: "index_product_reviews_on_user_id"
    end

    add_column :site_contents, :marquee_lines, :json, null: false, default: []
    add_column :site_contents, :whatsapp_number, :string, default: "", null: false
  end
end
