module Api
  module Admin
    class ProductsController < BaseController
      before_action :require_admin!

      def create
        b = json_body
        product = Product.new
        product.apply_api_attrs({
          tier: b["tier"].presence || "premium",
          tag: b["tag"].to_s,
          name: b["name"].to_s,
          description: b["description"].to_s,
          price: b["price"].to_f,
          imageUrl: b["imageUrl"].to_s,
          variants: Product.normalize_variants(b["variants"]),
          slug: b["slug"],
          compareAtPrice: b["compareAtPrice"],
          pdp: b["pdp"] || {}
        })
        product.save!
        render json: product.to_api
      end

      def update
        product = Product.find(params[:id])
        b = json_body
        attrs = {}
        %w[tier tag name description].each { |k| attrs[k.to_sym] = b[k] if b.key?(k) }
        attrs[:price] = b["price"].to_f if b.key?("price")
        attrs[:imageUrl] = b["imageUrl"] if b.key?("imageUrl")
        attrs[:variants] = b["variants"] if b.key?("variants")
        attrs[:slug] = b["slug"] if b.key?("slug")
        attrs[:compareAtPrice] = b["compareAtPrice"] if b.key?("compareAtPrice")
        attrs[:pdp] = b["pdp"] if b.key?("pdp")
        product.apply_api_attrs(attrs)
        product.save!
        render json: product.to_api
      end

      def destroy
        Product.find(params[:id]).destroy!
        render json: { success: true }
      end
    end
  end
end
