module Api
  module Admin
    class ConsultationsController < BaseController
      before_action :require_admin!

      def index
        items = Consultation.order(created_at: :desc).limit(500)
        render json: items.map(&:to_api)
      end
    end
  end
end
