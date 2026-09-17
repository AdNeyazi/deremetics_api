module Api
  class RootController < BaseController
    def show
      render json: { message: "DERMATICS API" }
    end
  end
end
