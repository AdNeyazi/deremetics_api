# Development only: set DEV_SIMULATE_CLIENT_IP in .env so Ahoy geocoding sees a public IP
# (localhost otherwise records :: or 127.0.0.1 with no city/country).
class DevSimulateClientIp
  def initialize(app)
    @app = app
  end

  def call(env)
    ip = ENV["DEV_SIMULATE_CLIENT_IP"].to_s.strip
    if ip.present?
      env["HTTP_X_FORWARDED_FOR"] = ip
      env["HTTP_X_REAL_IP"] = ip
    end
    @app.call(env)
  end
end
