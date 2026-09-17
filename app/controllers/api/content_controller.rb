module Api
  class ContentController < BaseController
    def show
      doc = SiteContent.find_by(key: "site")
      render json: doc ? doc.to_api : {}
    end
  end
end
