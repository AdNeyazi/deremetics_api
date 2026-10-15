# frozen_string_literal: true

class Phase1SitePdpSettings < ActiveRecord::Migration[8.1]
  def change
    change_table :site_contents, bulk: true do |t|
      t.integer :guarantee_days, null: false, default: 45
      t.boolean :trust_complimentary_gift, null: false, default: true
      t.boolean :trust_free_shipping, null: false, default: true
      t.boolean :trust_cod, null: false, default: true
      t.string :brand_trust_headline, null: false, default: ""
      t.string :brand_trust_promise, null: false, default: ""
    end
  end
end
