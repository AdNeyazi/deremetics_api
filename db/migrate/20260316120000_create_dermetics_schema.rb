class CreateDermeticsSchema < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :email, null: false
      t.string :name, null: false
      t.string :role, null: false, default: "user"
      t.string :password_digest, null: false
      t.boolean :active, null: false, default: true
      t.datetime :created_at, null: false
    end
    add_index :users, :email, unique: true

    create_table :products, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :tier, null: false
      t.string :tag, null: false, default: ""
      t.string :name, null: false
      t.text :description, null: false, default: ""
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0
      t.string :image_url, null: false, default: ""
      t.json :variants, null: false, default: []
    end
    add_index :products, :tier

    create_table :categories, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :key, null: false
      t.integer :order, null: false, default: 0
      t.string :label, null: false
      t.string :intro_title, null: false, default: ""
      t.text :intro_text, null: false, default: ""
    end

    create_table :site_contents, id: false do |t|
      t.string :key, null: false, primary_key: true
      t.string :hero_title, null: false, default: ""
      t.string :hero_sub, null: false, default: ""
      t.string :flagship_title, null: false, default: ""
      t.string :flagship_sub, null: false, default: ""
      t.string :what_title, null: false, default: ""
      t.text :what_text, null: false, default: ""
      t.string :why_title, null: false, default: ""
      t.text :why_text, null: false, default: ""
      t.json :process, null: false, default: []
      t.string :feedback_title, null: false, default: ""
      t.text :feedback_text, null: false, default: ""
      t.string :footer_heading, null: false, default: ""
      t.text :footer_text, null: false, default: ""
      t.string :phone, null: false, default: ""
    end

    create_table :team_members, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.integer :order, null: false, default: 0
      t.string :name, null: false
      t.string :role, null: false, default: ""
      t.text :bio, null: false, default: ""
      t.string :image_url, null: false, default: ""
    end

    create_table :faqs, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.integer :order, null: false, default: 0
      t.string :question, null: false
      t.text :answer, null: false, default: ""
    end

    create_table :packages, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.integer :order, null: false, default: 0
      t.string :name, null: false
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0
      t.text :description, null: false, default: ""
      t.boolean :recommended, null: false, default: false
      t.json :features, null: false, default: []
    end

    create_table :consultations, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :name, null: false
      t.string :phone, null: false
      t.string :email, null: false, default: ""
      t.string :tier, null: false, default: ""
      t.text :message, null: false, default: ""
      t.datetime :created_at, null: false
    end

    create_table :diagnostic_consultations, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :full_name, null: false
      t.string :email, null: false, default: ""
      t.string :phone, null: false
      t.text :address, null: false, default: ""
      t.string :blood_group, null: false, default: ""
      t.text :allergies, null: false, default: ""
      t.text :current_routine, null: false, default: ""
      t.json :report_file_ids, null: false, default: []
      t.json :face_photo_file_ids, null: false, default: []
      t.boolean :consent, null: false, default: false
      t.string :status, null: false, default: "New"
      t.string :user_id
      t.datetime :created_at, null: false
    end

    create_table :analytics_events, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :event_type, null: false
      t.string :page, null: false, default: "/"
      t.json :metadata, null: false, default: {}
      t.string :session_id
      t.string :user_id
      t.string :referrer, null: false, default: ""
      t.string :device, null: false, default: ""
      t.datetime :timestamp, null: false
    end
    add_index :analytics_events, :timestamp

    create_table :secure_files, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :original_name, null: false
      t.string :content_type, null: false
      t.string :ext, null: false
      t.integer :size, null: false, default: 0
      t.string :path, null: false
      t.datetime :created_at, null: false
    end
  end
end
