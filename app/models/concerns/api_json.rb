module ApiJson
  extend ActiveSupport::Concern

  def iso_time(value)
    value&.utc&.iso8601(3)
  end
end
