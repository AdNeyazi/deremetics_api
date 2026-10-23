# frozen_string_literal: true

require "test_helper"

class Ga4MeasurementProtocolServiceTest < ActiveSupport::TestCase
  test "enabled? returns false when environment variables are missing" do
    ENV["GA_MEASUREMENT_ID"] = nil
    ENV["GA_API_SECRET"] = nil

    assert_not Ga4MeasurementProtocolService.enabled?
  end

  test "enabled? returns true when both credentials are set" do
    ENV["GA_MEASUREMENT_ID"] = "G-TEST123456"
    ENV["GA_API_SECRET"] = "secret_token_123"

    assert Ga4MeasurementProtocolService.enabled?
  ensure
    ENV["GA_MEASUREMENT_ID"] = nil
    ENV["GA_API_SECRET"] = nil
  end

  test "send_event handles missing configuration gracefully" do
    ENV["GA_MEASUREMENT_ID"] = nil
    ENV["GA_API_SECRET"] = nil

    res = Ga4MeasurementProtocolService.send_event(client_id: "test-cid", name: "test_event")
    assert_equal false, res[:success]
    assert_includes res[:reason], "not configured"
  end
end
