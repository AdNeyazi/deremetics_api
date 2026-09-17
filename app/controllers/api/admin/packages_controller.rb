module Api
  module Admin
    class PackagesController < BaseController
      before_action :require_admin!

      def create
        b = json_body
        pkg = Package.create!(
          order: b["order"].to_i.nonzero? || 99,
          name: b["name"].to_s,
          price: b["price"].to_f,
          description: b["description"].to_s,
          recommended: !!b["recommended"],
          features: b["features"].is_a?(Array) ? b["features"] : []
        )
        render json: pkg.to_api
      end

      def update
        pkg = Package.find(params[:id])
        b = json_body
        pkg.order = b["order"].to_i if b.key?("order")
        pkg.name = b["name"] if b.key?("name")
        pkg.price = b["price"].to_f if b.key?("price")
        pkg.description = b["description"] if b.key?("description")
        pkg.recommended = b["recommended"] if b.key?("recommended")
        pkg.features = b["features"] if b["features"].is_a?(Array)
        pkg.save!
        render json: pkg.to_api
      end

      def destroy
        Package.find(params[:id]).destroy!
        render json: { success: true }
      end
    end
  end
end
