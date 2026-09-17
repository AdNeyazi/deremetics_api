module Api
  class AnalyticsEventsController < BaseController
    def create
      body = json_body
      auth = current_auth
      AnalyticsEvent.create!(
        event_type: body["event_type"].presence || "page_view",
        page: body["page"].presence || "/",
        metadata: body["metadata"].is_a?(Hash) ? body["metadata"] : {},
        session_id: body["session_id"],
        user_id: auth ? auth[:id] : body["user_id"],
        referrer: body["referrer"].to_s,
        device: body["device"].to_s,
        timestamp: Time.current
      )
      render json: { success: true }
    end
  end
end
