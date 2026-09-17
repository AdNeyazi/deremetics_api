module Api
  module Admin
    class ProductsController < BaseController
      before_action :require_admin!

      def create
        b = json_body
        product = Product.new(
          tier: b["tier"].presence || "premium",
          tag: b["tag"].to_s,
          name: b["name"].to_s,
          description: b["description"].to_s,
          price: b["price"].to_f,
          image_url: b["imageUrl"].to_s,
          variants: Product.normalize_variants(b["variants"])
        )
        product.save!
        render json: product.to_api
      end

      def update
        product = Product.find(params[:id])
        b = json_body
        attrs = {}
        attrs[:tier] = b["tier"] if b.key?("tier")
        attrs[:tag] = b["tag"] if b.key?("tag")
        attrs[:name] = b["name"] if b.key?("name")
        attrs[:description] = b["description"] if b.key?("description")
        attrs[:price] = b["price"].to_f if b.key?("price")
        attrs[:imageUrl] = b["imageUrl"] if b.key?("imageUrl")
        attrs[:variants] = b["variants"] if b.key?("variants")
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
