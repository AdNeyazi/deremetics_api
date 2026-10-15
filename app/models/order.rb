# frozen_string_literal: true

class Order < ApplicationRecord
  include ApiJson

  self.primary_key = "id"
  STATUSES = %w[pending paid failed cancelled].freeze
  PAYMENT_METHODS = %w[cod online].freeze

  has_many :order_items, dependent: :destroy

  belongs_to :user, foreign_key: :user_id, primary_key: :id, optional: true

  before_validation :assign_id, on: :create

  validates :status, inclusion: { in: STATUSES }
  validates :payment_method, inclusion: { in: PAYMENT_METHODS }
  validates :customer_name, :customer_phone, presence: true
  validates :total, numericality: { greater_than_or_equal_to: 0 }

  scope :paid, -> { where(status: "paid") }

  def self.user_purchased_product?(user_id, product_id)
    return false if user_id.blank? || product_id.blank?

    OrderItem.joins(:order)
             .where(orders: { user_id: user_id, status: "paid" }, product_id: product_id)
             .exists?
  end

  def to_api
    {
      id: id,
      status: status,
      paymentMethod: payment_method,
      couponCode: coupon_code,
      referralCode: referral_code,
      subtotal: subtotal.to_f,
      discount: discount.to_f,
      shipping: shipping.to_f,
      total: total.to_f,
      currency: currency,
      customerName: customer_name,
      customerEmail: customer_email,
      customerPhone: customer_phone,
      shippingAddress: shipping_address,
      shippingCity: shipping_city,
      shippingState: shipping_state,
      shippingPincode: shipping_pincode,
      items: order_items.map(&:to_api),
      createdAt: created_at&.iso8601
    }
  end

  private

  def assign_id
    self.id ||= SecureRandom.uuid
  end
end
