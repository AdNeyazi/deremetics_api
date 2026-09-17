module Api
  module Admin
    class DiagnosticConsultationsController < BaseController
      before_action :require_admin!

      def index
        items = DiagnosticConsultation.order(created_at: :desc).limit(500)
        render json: items.map(&:to_api)
      end

      def update
        item = DiagnosticConsultation.find(params[:id])
        item.status = json_body["status"] if json_body.key?("status")
        item.save!
        render json: item.to_api
      end
    end
  end
end
