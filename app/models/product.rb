# frozen_string_literal: true

class Product < ApplicationRecord
  include ApiJson

  self.primary_key = "id"
  TIERS = %w[premium ultra].freeze

  has_many :product_reviews, dependent: :destroy

  before_validation :assign_id, on: :create
  before_validation :assign_slug

  validates :tier, inclusion: { in: TIERS }
  validates :name, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 5000 }
  validates :tag, length: { maximum: 100 }
  validates :price, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1_000_000 }
  validates :compare_at_price, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1_000_000 }, allow_nil: true
  validates :slug, presence: true, uniqueness: true, length: { maximum: 200 }
  validates :image_url, length: { maximum: 2048 },
                        format: { with: %r{\Ahttps?://\S+\z}i, message: "must be an http(s) URL" },
                        allow_blank: true
  validate :variants_limit

  def self.find_by_param!(param)
    find_by(slug: param) || find(param)
  end

  def to_api(include_reviews: false)
    payload = {
      id: id,
      slug: slug,
      tier: tier,
      tag: tag,
      name: name,
      description: description,
      price: price.to_f,
      compareAtPrice: compare_at_price&.to_f,
      imageUrl: image_url,
      variants: normalized_variants_api,
      pdp: pdp_for_api
    }
    if include_reviews
      summary = ProductReview.summary_for(id)
      payload[:reviewSummary] = {
        average: summary[:average],
        count: summary[:count],
        distribution: summary[:distribution]
      }
      payload[:reviews] = product_reviews.approved.order(created_at: :desc).limit(50).map(&:to_api)
    end
    payload
  end

  def normalized_variants_api
    (variants || []).map do |v|
      h = v.is_a?(Hash) ? v : {}
      {
        label: h["label"] || h[:label] || "",
        price: (h["price"] || h[:price] || 0).to_f,
        mrp: (h["mrp"] || h[:mrp]).nil? ? nil : (h["mrp"] || h[:mrp]).to_f,
        imageUrl: h["imageUrl"] || h[:imageUrl] || "",
        inStock: h.key?("inStock") || h.key?(:inStock) ? !!(h["inStock"].nil? ? h[:inStock] : h["inStock"]) : true
      }
    end
  end

  def pdp_for_api
    n = normalize_pdp(pdp)
    {
      highlightLine: n["highlightLine"],
      highlightBadge: n["badge"],
      subtitle: n["subtitle"],
      badge: n["badge"],
      dermatologicallyTested: n["dermatologicallyTested"],
      media: n["media"],
      gallery: n["gallery"],
      formulatedFor: n["formulatedFor"],
      freeFrom: n["freeFrom"],
      proTips: n["proTips"],
      highlights: {
        formulatedFor: n["formulatedFor"].map { |x| x["label"] },
        freeFrom: n["freeFrom"].map { |x| x["label"] },
        tips: n["proTips"].map { |x| x["label"] }
      },
      taxInclusive: n["taxInclusive"],
      currency: n["currency"],
      trust: n["trust"],
      guarantee: n["guarantee"],
      actionVideos: n["actionVideos"],
      stats: n["stats"],
      heroBanner: n["heroBanner"],
      blendMarquee: n["blendMarquee"],
      story: n["story"].merge(richText: n["story"]["body"]),
      benefitBanners: n["benefitBanners"],
      ingredients: n["ingredients"],
      inciText: n["inciText"],
      infoTabs: n["infoTabs"],
      sections: n["sections"],
      faqs: n["faqs"],
      relatedProductIds: n["relatedProductIds"],
      bundleItems: n["bundleItems"],
      eligibleCoupons: n["eligibleCoupons"],
      seo: n["seo"]
    }
  end

  def apply_api_attrs(attrs)
    attrs.each do |key, value|
      next if value.nil? && key.to_sym != :compareAtPrice && key.to_sym != :compare_at_price

      case key.to_sym
      when :tier then self.tier = value
      when :tag then self.tag = value
      when :name then self.name = value
      when :description then self.description = value
      when :price then self.price = value
      when :imageUrl then self.image_url = value
      when :variants then self.variants = normalize_variants(value)
      when :slug then self.slug = value.to_s.presence
      when :compareAtPrice, :compare_at_price then self.compare_at_price = value.presence
      when :pdp then self.pdp = self.class.normalize_pdp(value)
      end
    end
  end

  def self.normalize_variants(list)
    return [] unless list.is_a?(Array)

    list.map do |v|
      {
        "label" => (v["label"] || v[:label] || "").to_s,
        "price" => (v["price"] || v[:price] || 0).to_f,
        "mrp" => begin
          raw = v["mrp"] || v[:mrp]
          raw.nil? || raw == "" ? nil : raw.to_f
        end,
        "imageUrl" => (v["imageUrl"] || v[:imageUrl] || "").to_s,
        "inStock" => v.key?("inStock") || v.key?(:inStock) ? !!(v["inStock"].nil? ? v[:inStock] : v["inStock"]) : true
      }
    end
  end

  def self.normalize_pdp(raw)
    h = raw.is_a?(Hash) ? raw.stringify_keys : {}
    highlights = normalize_highlights(h["highlights"])
    formulated = list_of_labels(h["formulatedFor"] || h["formulated_for"]).presence ||
                 highlights["formulatedFor"].map { |l| { "label" => l, "icon" => "" } }
    free = list_of_labels(h["freeFrom"] || h["free_from"]).presence ||
           highlights["freeFrom"].map { |l| { "label" => l, "icon" => "" } }
    tips = list_of_labels(h["proTips"] || h["pro_tips"] || h["tips"]).presence ||
           highlights["tips"].map { |l| { "label" => l, "icon" => "" } }

    media = normalize_media(h["media"])
    gallery = Array(h["gallery"]).map(&:to_s).reject(&:blank?)
    gallery = media.select { |m| m["type"] == "image" }.map { |m| m["url"] } if gallery.blank? && media.any?

    trust = hash_str(h["trust"])
    guarantee = hash_str(h["guarantee"])
    hero = hash_str(h["heroBanner"] || h["hero_banner"])
    story = hash_str(h["story"])
    seo = hash_str(h["seo"])
    blend = hash_str(h["blendMarquee"] || h["blend_marquee"])
    info = hash_str(h["infoTabs"] || h["info_tabs"])
    badge_text = (h["badge"] || h["highlight_badge"] || h["highlightBadge"] || "").to_s

    sections = Array(h["sections"]).map { |s| normalize_section(s) }.compact
    if sections.blank?
      sections = [
        { "title" => "Formulation Overview", "body" => (info["overview"] || "").to_s },
        { "title" => "Application Protocol", "body" => (info["applicationProtocol"] || info["application_protocol"] || "").to_s },
        { "title" => "More Details", "body" => (info["moreDetails"] || info["more_details"] || "").to_s }
      ].reject { |s| s["body"].blank? }
    end

    {
      "highlightLine" => (h["highlightLine"] || h["highlight_line"] || "").to_s,
      "subtitle" => (h["subtitle"] || "").to_s,
      "badge" => badge_text,
      "dermatologicallyTested" => h.key?("dermatologicallyTested") ? !!h["dermatologicallyTested"] : false,
      "media" => media,
      "gallery" => gallery,
      "formulatedFor" => formulated,
      "freeFrom" => free,
      "proTips" => tips,
      "taxInclusive" => h.key?("taxInclusive") ? !!h["taxInclusive"] : true,
      "currency" => (h["currency"].presence || "INR").to_s,
      "trust" => {
        "freeShipping" => trust.key?("freeShipping") ? !!trust["freeShipping"] : true,
        "cod" => trust.key?("cod") ? !!trust["cod"] : true,
        "gift" => trust.key?("gift") ? !!trust["gift"] : true
      },
      "guarantee" => {
        "title" => (guarantee["title"] || "").to_s,
        "body" => (guarantee["body"] || "").to_s
      },
      "actionVideos" => Array(h["actionVideos"] || h["action_videos"]).map { |v| normalize_action_video(v) }.compact,
      "stats" => Array(h["stats"]).map { |s| normalize_stat(s) }.compact,
      "heroBanner" => {
        "sectionHeading" => (hero["sectionHeading"] || hero["section_heading"] || "").to_s,
        "headline" => (hero["headline"] || "").to_s,
        "lines" => Array(hero["lines"]).map(&:to_s),
        "desktopImage" => (hero["desktopImage"] || hero["desktop_image"] || "").to_s,
        "mobileImage" => (hero["mobileImage"] || hero["mobile_image"] || "").to_s
      },
      "blendMarquee" => {
        "title" => (blend["title"] || "").to_s,
        "descriptors" => Array(blend["descriptors"]).map(&:to_s).reject(&:blank?)
      },
      "story" => {
        "image" => (story["image"] || "").to_s,
        "title" => (story["title"] || "").to_s,
        "body" => (story["body"] || "").to_s
      },
      "benefitBanners" => Array(h["benefitBanners"] || h["benefit_banners"]).map { |b| normalize_banner(b) }.compact,
      "ingredients" => Array(h["ingredients"]).map { |s| normalize_ingredient(s) }.compact,
      "inciText" => (h["inciText"] || h["inci_text"] || "").to_s,
      "infoTabs" => {
        "overview" => (info["overview"] || sections.find { |s| s["title"].to_s.downcase.include?("overview") }&.dig("body") || "").to_s,
        "applicationProtocol" => (info["applicationProtocol"] || info["application_protocol"] || sections.find { |s| s["title"].to_s.downcase.include?("application") }&.dig("body") || "").to_s,
        "moreDetails" => (info["moreDetails"] || info["more_details"] || sections.find { |s| s["title"].to_s.downcase.include?("more") }&.dig("body") || "").to_s
      },
      "sections" => sections,
      "faqs" => Array(h["faqs"]).map { |s| normalize_faq(s) }.compact,
      "relatedProductIds" => Array(h["relatedProductIds"] || h["related_product_ids"]).map(&:to_s),
      "bundleItems" => Array(h["bundleItems"] || h["bundle_items"]).map { |b| normalize_bundle(b) }.compact,
      "eligibleCoupons" => Array(h["eligibleCoupons"] || h["eligible_coupons"]).map { |c| normalize_coupon(c) }.compact,
      "seo" => {
        "title" => (seo["title"] || "").to_s,
        "description" => (seo["description"] || "").to_s,
        "ogImage" => (seo["ogImage"] || seo["og_image"] || "").to_s
      }
    }
  end

  def self.slugify(name)
    name.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "").presence || "product"
  end

  def variants_limit
    errors.add(:variants, "has too many entries") if variants.is_a?(Array) && variants.size > 20
  end

  private

  def assign_id
    self.id ||= SecureRandom.uuid
  end

  def assign_slug
    base = slug.presence || self.class.slugify(name)
    return if base.blank?

    candidate = base
    n = 2
    while Product.where(slug: candidate).where.not(id: id).exists?
      candidate = "#{base}-#{n}"
      n += 1
    end
    self.slug = candidate
  end

  def normalize_variants(list)
    self.class.normalize_variants(list)
  end

  def normalize_pdp(raw)
    self.class.normalize_pdp(raw)
  end

  def self.hash_str(raw)
    raw.is_a?(Hash) ? raw.stringify_keys : {}
  end

  def self.list_of_labels(raw)
    Array(raw).filter_map do |item|
      if item.is_a?(Hash)
        label = (item["label"] || item[:label] || "").to_s
        next if label.blank?

        { "label" => label, "icon" => (item["icon"] || item[:icon] || "").to_s }
      else
        label = item.to_s
        next if label.blank?

        { "label" => label, "icon" => "" }
      end
    end
  end

  def self.normalize_highlights(raw)
    h = raw.is_a?(Hash) ? raw.stringify_keys : {}
    {
      "formulatedFor" => Array(h["formulatedFor"] || h["formulated_for"]).map(&:to_s),
      "freeFrom" => Array(h["freeFrom"] || h["free_from"]).map(&:to_s),
      "tips" => Array(h["tips"] || h["proTips"]).map(&:to_s)
    }
  end

  def self.normalize_media(raw)
    Array(raw).each_with_index.filter_map do |m, i|
      next unless m.is_a?(Hash)

      url = (m["url"] || m[:url] || "").to_s
      next if url.blank?

      {
        "type" => %w[image video].include?((m["type"] || m[:type] || "image").to_s) ? (m["type"] || m[:type] || "image").to_s : "image",
        "url" => url,
        "order" => (m["order"] || m[:order] || i).to_i,
        "variantLabel" => (m["variantLabel"] || m["variant_label"] || m[:variantLabel] || "").to_s
      }
    end.sort_by { |m| m["order"] }
  end

  def self.normalize_stat(s)
    return nil unless s.is_a?(Hash)

    {
      "value" => (s["value"] || s[:value] || "").to_s.gsub(/[^0-9.]/, ""),
      "suffix" => (s["suffix"] || s[:suffix] || (s["value"].to_s[/[^\d.]+$/] || "")).to_s,
      "label" => (s["label"] || s[:label] || "").to_s
    }
  end

  def self.normalize_ingredient(s)
    return nil unless s.is_a?(Hash)

    {
      "name" => (s["name"] || s[:name] || "").to_s,
      "role" => (s["role"] || s[:role] || "").to_s,
      "description" => (s["description"] || s[:description] || "").to_s,
      "imageUrl" => (s["imageUrl"] || s["image"] || s[:imageUrl] || s[:image] || "").to_s,
      "researchUrl" => (s["researchUrl"] || s["research_url"] || s[:researchUrl] || "").to_s
    }
  end

  def self.normalize_section(s)
    return nil unless s.is_a?(Hash)

    {
      "title" => (s["title"] || s[:title] || "").to_s,
      "body" => (s["body"] || s[:body] || "").to_s
    }
  end

  def self.normalize_faq(s)
    return nil unless s.is_a?(Hash)

    {
      "question" => (s["question"] || s[:question] || "").to_s,
      "answer" => (s["answer"] || s[:answer] || "").to_s,
      "order" => (s["order"] || s[:order] || 0).to_i
    }
  end

  def self.normalize_banner(b)
    return nil unless b.is_a?(Hash)

    {
      "desktopImage" => (b["desktopImage"] || b["desktop_image"] || "").to_s,
      "mobileImage" => (b["mobileImage"] || b["mobile_image"] || "").to_s,
      "alt" => (b["alt"] || "").to_s,
      "order" => (b["order"] || 0).to_i
    }
  end

  def self.normalize_action_video(v)
    return nil unless v.is_a?(Hash)

    url = (v["url"] || v[:url] || "").to_s
    return nil if url.blank?

    {
      "url" => url,
      "thumb" => (v["thumb"] || v[:thumb] || "").to_s,
      "title" => (v["title"] || v[:title] || "").to_s
    }
  end

  def self.normalize_bundle(b)
    return nil unless b.is_a?(Hash)

    id = (b["productId"] || b["product_id"] || "").to_s
    return nil if id.blank?

    { "productId" => id, "variantLabel" => (b["variantLabel"] || b["variant_label"] || "").to_s }
  end

  def self.normalize_coupon(c)
    return nil unless c.is_a?(Hash)

    code = (c["code"] || c[:code] || "").to_s
    return nil if code.blank?

    { "code" => code, "label" => (c["label"] || c[:label] || code).to_s }
  end
end
