module Api
  class CategoriesController < BaseController
    def index
      render json: Category.order(:order).map(&:to_api)
    end
  end
end
