# frozen_string_literal: true

module Api
  class ProductsController < BaseController
    def index
      scope = Product.all
      scope = scope.where(tier: params[:tier]) if params[:tier].present?
      render json: scope.map { |p| p.to_api }
    end

    def show
      product = Product.find_by_param!(params[:id])
      payload = product.to_api(include_reviews: true)

      related_ids = Array(payload.dig(:pdp, :relatedProductIds))
      if related_ids.any?
        related = Product.where(id: related_ids).index_by(&:id)
        payload[:relatedProducts] = related_ids.filter_map { |rid| related[rid]&.to_api }
      else
        payload[:relatedProducts] = Product.where(tier: product.tier).where.not(id: product.id).limit(6).map(&:to_api)
      end

      bundle_ids = Array(payload.dig(:pdp, :bundleItems)).map { |b| b[:productId] || b["productId"] }
      if bundle_ids.any?
        bundled = Product.where(id: bundle_ids).index_by(&:id)
        payload[:bundleProducts] = Array(payload.dig(:pdp, :bundleItems)).filter_map do |item|
          pid = item[:productId] || item["productId"]
          bp = bundled[pid]
          next unless bp

          bp.to_api.merge(bundleVariantLabel: item[:variantLabel] || item["variantLabel"])
        end
      else
        payload[:bundleProducts] = []
      end

      render json: payload
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Product not found" }, status: :not_found
    end
  end
end
