class Package < ApplicationRecord
  include ApiJson

  self.primary_key = "id"

  before_validation :assign_id, on: :create

  validates :name, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 2000 }
  validates :price, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1_000_000 }
  validate :features_limit

  def to_api
    {
      id: id,
      order: order,
      name: name,
      price: price.to_f,
      description: description,
      recommended: recommended,
      features: features || []
    }
  end

  def features_limit
    errors.add(:features, "has too many entries") if features.is_a?(Array) && features.size > 30
  end

  private

  def assign_id
    self.id ||= SecureRandom.uuid
  end
end
