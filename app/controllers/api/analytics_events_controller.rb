module Api
  class AnalyticsEventsController < BaseController
    # Legacy endpoint — forwards to Ahoy until the Next.js client uses /api/track/*.
    def create
      AnalyticsTracking.new(self, json_body).track_event!
      render json: { success: true }
    end
  end
end
