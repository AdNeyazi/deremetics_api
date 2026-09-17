class AnalyticsEvent < ApplicationRecord
  include ApiJson

  self.primary_key = "id"

  before_validation :assign_id, on: :create

  def to_api
    {
      id: id,
      event_type: event_type,
      page: page,
      metadata: metadata || {},
      session_id: session_id,
      user_id: user_id,
      referrer: referrer,
      device: device,
      timestamp: iso_time(timestamp)
    }
  end

  private

  def assign_id
    self.id ||= SecureRandom.uuid
  end
end
