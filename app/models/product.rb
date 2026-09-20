class Product < ApplicationRecord
  include ApiJson

  self.primary_key = "id"
  TIERS = %w[premium ultra].freeze

  before_validation :assign_id, on: :create

  validates :tier, inclusion: { in: TIERS }
  validates :name, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 5000 }
  validates :tag, length: { maximum: 100 }
  validates :price, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1_000_000 }
  validates :image_url, length: { maximum: 2048 },
                        format: { with: %r{\Ahttps?://\S+\z}i, message: "must be an http(s) URL" },
                        allow_blank: true
  validate :variants_limit

  def to_api
    {
      id: id,
      tier: tier,
      tag: tag,
      name: name,
      description: description,
      price: price.to_f,
      imageUrl: image_url,
      variants: (variants || []).map do |v|
        h = v.is_a?(Hash) ? v : {}
        {
          label: h["label"] || h[:label] || "",
          price: (h["price"] || h[:price] || 0).to_f,
          imageUrl: h["imageUrl"] || h[:imageUrl] || ""
        }
      end
    }
  end

  def apply_api_attrs(attrs)
    attrs.each do |key, value|
      next if value.nil?

      case key.to_sym
      when :tier then self.tier = value
      when :tag then self.tag = value
      when :name then self.name = value
      when :description then self.description = value
      when :price then self.price = value
      when :imageUrl then self.image_url = value
      when :variants then self.variants = normalize_variants(value)
      end
    end
  end

  def self.normalize_variants(list)
    return [] unless list.is_a?(Array)

    list.map do |v|
      {
        "label" => (v["label"] || v[:label] || "").to_s,
        "price" => (v["price"] || v[:price] || 0).to_f,
        "imageUrl" => (v["imageUrl"] || v[:imageUrl] || "").to_s
      }
    end
  end

  def variants_limit
    errors.add(:variants, "has too many entries") if variants.is_a?(Array) && variants.size > 20
  end

  private

  def assign_id
    self.id ||= SecureRandom.uuid
  end

  def normalize_variants(list)
    self.class.normalize_variants(list)
  end
end
