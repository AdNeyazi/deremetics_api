# frozen_string_literal: true

class OrderItem < ApplicationRecord
  include ApiJson

  self.primary_key = "id"

  belongs_to :order, foreign_key: :order_id, primary_key: :id
  belongs_to :product, foreign_key: :product_id, primary_key: :id, optional: true

  before_validation :assign_id, on: :create

  validates :order_id, :product_id, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0, less_than: 100 }

  def to_api
    {
      id: id,
      productId: product_id,
      productName: product_name,
      variantLabel: variant_label,
      quantity: quantity,
      unitPrice: unit_price.to_f,
      lineTotal: line_total.to_f
    }
  end

  private

  def assign_id
    self.id ||= SecureRandom.uuid
  end
end
