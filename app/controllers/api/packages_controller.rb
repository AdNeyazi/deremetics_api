module Api
  class PackagesController < BaseController
    def index
      render json: Package.order(:order).map(&:to_api)
    end
  end
end
