module Api
  module Admin
    class AnalyticsController < BaseController
      before_action :require_admin!

      def overview
        render json: AnalyticsOverview.build
      end
    end
  end
end
