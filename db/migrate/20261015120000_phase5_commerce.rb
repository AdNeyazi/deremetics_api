# frozen_string_literal: true

class Phase5Commerce < ActiveRecord::Migration[8.1]
  def change
    create_table :coupons, id: :string do |t|
      t.string :code, null: false
      t.string :label, default: "", null: false
      t.string :discount_type, default: "percent", null: false
      t.decimal :discount_value, precision: 10, scale: 2, default: "0.0", null: false
      t.decimal :min_subtotal, precision: 10, scale: 2
      t.boolean :active, default: true, null: false
      t.datetime :expires_at
      t.timestamps
    end
    add_index :coupons, :code, unique: true

    create_table :orders, id: :string do |t|
      t.string :user_id
      t.string :status, default: "pending", null: false
      t.string :payment_method, default: "cod", null: false
      t.string :payment_provider, default: "", null: false
      t.string :payment_reference, default: "", null: false
      t.string :coupon_code, default: "", null: false
      t.string :referral_code, default: "", null: false
      t.decimal :subtotal, precision: 10, scale: 2, default: "0.0", null: false
      t.decimal :discount, precision: 10, scale: 2, default: "0.0", null: false
      t.decimal :shipping, precision: 10, scale: 2, default: "0.0", null: false
      t.decimal :total, precision: 10, scale: 2, default: "0.0", null: false
      t.string :currency, default: "INR", null: false
      t.string :customer_name, null: false
      t.string :customer_email, default: "", null: false
      t.string :customer_phone, null: false
      t.text :shipping_address, default: "", null: false
      t.string :shipping_city, default: "", null: false
      t.string :shipping_state, default: "", null: false
      t.string :shipping_pincode, default: "", null: false
      t.timestamps
    end
    add_index :orders, :user_id
    add_index :orders, :status
    add_index :orders, :created_at

    create_table :order_items, id: :string do |t|
      t.string :order_id, null: false
      t.string :product_id, null: false
      t.string :product_name, default: "", null: false
      t.string :variant_label, default: "", null: false
      t.integer :quantity, default: 1, null: false
      t.decimal :unit_price, precision: 10, scale: 2, default: "0.0", null: false
      t.decimal :line_total, precision: 10, scale: 2, default: "0.0", null: false
      t.timestamps
    end
    add_index :order_items, :order_id
    add_index :order_items, :product_id
  end
end
