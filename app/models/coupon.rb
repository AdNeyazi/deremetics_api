# frozen_string_literal: true

class Coupon < ApplicationRecord
  include ApiJson

  self.primary_key = "id"
  TYPES = %w[percent fixed].freeze

  before_validation :assign_id, on: :create
  before_validation :normalize_code

  validates :code, presence: true, uniqueness: true
  validates :discount_type, inclusion: { in: TYPES }
  validates :discount_value, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true).where("expires_at IS NULL OR expires_at > ?", Time.current) }

  def self.find_valid!(code)
    active.find_by!(code: code.to_s.strip.upcase)
  end

  def apply_to(subtotal)
    base = subtotal.to_d
    return { discount: 0.to_d, total: base } if min_subtotal.present? && base < min_subtotal.to_d

    disc = if discount_type == "fixed"
      discount_value.to_d.clamp(0, base)
    else
      (base * (discount_value.to_d / 100)).round(2)
    end
    { discount: disc, total: (base - disc).round(2) }
  end

  def to_api
    {
      code: code,
      label: label.presence || code,
      discountType: discount_type,
      discountValue: discount_value.to_f
    }
  end

  private

  def assign_id
    self.id ||= SecureRandom.uuid
  end

  def normalize_code
    self.code = code.to_s.strip.upcase
  end
end
