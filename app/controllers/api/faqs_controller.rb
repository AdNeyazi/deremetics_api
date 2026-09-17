module Api
  class FaqsController < BaseController
    def index
      render json: Faq.order(:order).map(&:to_api)
    end
  end
end
