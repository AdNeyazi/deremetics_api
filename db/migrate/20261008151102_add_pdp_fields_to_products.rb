# frozen_string_literal: true

class AddPdpFieldsToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :slug, :string
    add_column :products, :compare_at_price, :decimal, precision: 10, scale: 2
    add_column :products, :pdp, :json, null: false, default: {}
    add_index :products, :slug, unique: true
  end
end
