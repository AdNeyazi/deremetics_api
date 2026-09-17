module Api
  class ProductsController < BaseController
    def index
      scope = Product.all
      scope = scope.where(tier: params[:tier]) if params[:tier].present?
      render json: scope.map(&:to_api)
    end
  end
end
