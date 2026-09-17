class Product < ApplicationRecord
  include ApiJson

  self.primary_key = "id"

  before_validation :assign_id, on: :create

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

  private

  def assign_id
    self.id ||= SecureRandom.uuid
  end

  def normalize_variants(list)
    self.class.normalize_variants(list)
  end
end
