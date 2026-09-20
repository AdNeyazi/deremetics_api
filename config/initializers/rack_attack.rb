class Rack::Attack
  # Counters live in this process's memory: fine for one server with one Puma
  # process, and they reset on restart. Move to Redis if you scale out.
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Real client IP as resolved by Rails (works behind the Kamal proxy).
  CLIENT_IP = lambda { |req| (req.env["action_dispatch.remote_ip"] || req.ip).to_s }

  # Normalised path, so "/api/auth/login/", "/api/auth/login.json" and
  # "//api/auth/%6cogin" cannot dodge the rules.
  PATH = lambda do |req|
    Rack::Utils.unescape_path(req.path).squeeze("/").sub(%r{/+\z}, "").sub(/\.\w+\z/, "")
  end

  # Reads "email" from a small JSON body without consuming it.
  EMAIL_FROM_BODY = lambda do |req|
    next nil unless req.content_type.to_s.include?("application/json")

    raw = req.body.read(10_000)
    req.body.rewind if req.body.respond_to?(:rewind)
    email = JSON.parse(raw.to_s)["email"] rescue nil
    email.is_a?(String) ? email.downcase.strip.presence : nil
  end

  # --- Login: slow down password guessing ---
  throttle("login/ip", limit: 10, period: 1.minute) do |req|
    CLIENT_IP.call(req) if req.post? && PATH.call(req) == "/api/auth/login"
  end

  throttle("login/email", limit: 5, period: 1.minute) do |req|
    EMAIL_FROM_BODY.call(req) if req.post? && PATH.call(req) == "/api/auth/login"
  end

  # --- Signup ---
  throttle("register/ip", limit: 10, period: 1.hour) do |req|
    CLIENT_IP.call(req) if req.post? && PATH.call(req) == "/api/auth/register"
  end

  # --- Uploads (a file is sent as many small chunks, so this is generous) ---
  throttle("uploads/ip", limit: 300, period: 10.minutes) do |req|
    CLIENT_IP.call(req) if req.post? && PATH.call(req).start_with?("/api/upload/")
  end

  # --- Public forms ---
  throttle("forms/ip", limit: 5, period: 10.minutes) do |req|
    if req.post? && %w[/api/consultation /api/diagnostic-consultation].include?(PATH.call(req))
      CLIENT_IP.call(req)
    end
  end

  throttle("analytics/ip", limit: 120, period: 1.minute) do |req|
    CLIENT_IP.call(req) if req.post? && PATH.call(req) == "/api/analytics/event"
  end

  # --- Overall safety net for everything under /api ---
  throttle("api/ip", limit: 600, period: 1.minute) do |req|
    CLIENT_IP.call(req) if PATH.call(req).start_with?("/api")
  end

  # JSON 429 response with a Retry-After header.
  self.throttled_responder = lambda do |req|
    match = req.env["rack.attack.match_data"]
    retry_after = match[:period] - (match[:epoch_time] % match[:period])
    [
      429,
      { "content-type" => "application/json", "retry-after" => retry_after.to_s },
      [ { error: "Too many requests. Please try again later." }.to_json ]
    ]
  end
end

# Log which rule fired (no personal data).
ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _id, payload|
  req = payload[:request]
  Rails.logger.warn("[rack-attack] throttled rule=#{req.env['rack.attack.matched']} #{req.request_method} #{req.path}")
end
