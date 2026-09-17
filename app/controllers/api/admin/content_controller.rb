module Api
  module Admin
    class ContentController < BaseController
      before_action :require_admin!

      def update
        doc = SiteContent.find_or_initialize_by(key: "site")
        doc.apply_api_attrs(json_body.except("_id", "key"))
        doc.save!
        render json: doc.to_api
      end
    end
  end
end
