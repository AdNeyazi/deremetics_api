class AnalyticsTracking
  def initialize(controller, body = {})
    @controller = controller
    @body = body.is_a?(Hash) ? body.stringify_keys : {}
  end

  def register_visit!
    visitor_token = normalized_token(@body["visitor_token"]) || SecureRandom.uuid
    visit_token = SecureRandom.uuid

    tracker = build_tracker(visit_token: visit_token, visitor_token: visitor_token)
    tracker.track_visit
    sync_visit_record!(visit_token, visitor_token)

    { visitToken: visit_token, visitorToken: visitor_token }
  end

  def track_event!
    name = @body["name"].presence || @body["event_type"].presence || "page_view"
    visitor_token = normalized_token(@body["visitor_token"].presence || @body["session_id"]) || SecureRandom.uuid
    visit_token = resolve_visit_token(visitor_token)

    tracker = build_tracker(visit_token: visit_token, visitor_token: visitor_token)
    ensure_visit!(tracker, visit_token, visitor_token)
    tracker.track(name, event_properties)
    { success: true }
  end

  private

  def build_tracker(visit_token:, visitor_token:)
    Ahoy::Tracker.new(
      controller: @controller,
      request: @controller.request,
      visit_token: visit_token,
      visitor_token: visitor_token
    )
  end

  def resolve_visit_token(visitor_token)
    explicit = normalized_token(@body["visit_token"])
    return explicit if explicit.present?

    recent = Ahoy::Visit.where(visitor_token: visitor_token)
                        .where(started_at: Ahoy.visit_duration.ago..)
                        .order(started_at: :desc)
                        .first
    recent&.visit_token || SecureRandom.uuid
  end

  def ensure_visit!(tracker, visit_token, visitor_token)
    return if Ahoy::Visit.exists?(visit_token: visit_token)

    tracker.track_visit
    sync_visit_record!(visit_token, visitor_token)
  end

  def event_properties
    props = @body["properties"].is_a?(Hash) ? @body["properties"].stringify_keys : {}
    meta = @body["metadata"]
    props.merge!(meta.stringify_keys) if meta.is_a?(Hash)
    props["page"] = @body["page"] if @body["page"].present?
    props["referrer"] = @body["referrer"] if @body["referrer"].present?
    props["device"] = @body["device"] if @body["device"].present?
    props
  end

  def sync_visit_record!(visit_token, visitor_token)
    visit = Ahoy::Visit.find_by(visit_token: visit_token)
    return unless visit

    attrs = {}
    attrs[:visitor_token] = visitor_token if visitor_token.present?
    page = @body["page"].presence || @body["landing_page"].presence
    attrs[:landing_page] = page if page.present?
    attrs[:referrer] = @body["referrer"].to_s if @body.key?("referrer")
    visit.update!(attrs) if attrs.any?
  end

  def normalized_token(value)
    token = value.to_s.gsub(/[^a-z0-9\-]/i, "").first(64)
    token.presence
  end
end
