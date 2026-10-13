module Api
  class TrackingController < BaseController
    def visit
      payload = AnalyticsTracking.new(self, json_body).register_visit!
      render json: payload
    end

    def event
      AnalyticsTracking.new(self, json_body).track_event!
      render json: { success: true }
    end
  end
end
