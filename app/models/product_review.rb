# frozen_string_literal: true

class ProductReview < ApplicationRecord
  include ApiJson

  self.primary_key = "id"
  STATUSES = %w[pending approved rejected].freeze

  belongs_to :product, foreign_key: :product_id, primary_key: :id, optional: true
  belongs_to :user, foreign_key: :user_id, primary_key: :id, optional: true

  before_validation :assign_id, on: :create

  validates :product_id, presence: true
  validates :rating, inclusion: { in: 1..5 }
  validates :status, inclusion: { in: STATUSES }
  validates :title, length: { maximum: 200 }
  validates :body, length: { maximum: 5000 }
  validates :author_name, length: { maximum: 120 }

  scope :approved, -> { where(status: "approved") }
  scope :pending, -> { where(status: "pending") }

  def to_api
    {
      id: id,
      productId: product_id,
      userId: user_id,
      authorName: author_name.presence || "Guest",
      rating: rating,
      title: title,
      body: body,
      photos: photos || [],
      status: status,
      verifiedPurchase: verified_purchase,
      createdAt: created_at&.iso8601
    }
  end

  def to_admin_api
    to_api.merge(productName: product&.name)
  end

  def self.summary_for(product_id)
    rows = approved.where(product_id: product_id)
    total = rows.count
    return { average: 0, count: 0, distribution: { 5 => 0, 4 => 0, 3 => 0, 2 => 0, 1 => 0 } } if total.zero?

    dist = { 5 => 0, 4 => 0, 3 => 0, 2 => 0, 1 => 0 }
    sum = 0
    rows.pluck(:rating).each do |r|
      dist[r] = dist[r].to_i + 1
      sum += r
    end
    { average: (sum.to_f / total).round(2), count: total, distribution: dist }
  end

  private

  def assign_id
    self.id ||= SecureRandom.uuid
  end
end
