class Ahoy::Store < Ahoy::DatabaseStore
  # Privacy: keep city/region/country only — do not persist precise coordinates.
  def geocode(data)
    data.delete(:latitude)
    data.delete(:longitude)
    super
  end
end

# Next.js uses custom /api/track/* endpoints (Phase 2), not Ahoy.js or /ahoy/* engine routes.
Ahoy.api = false
Ahoy.api_only = true
Ahoy.server_side_visits = :when_needed

# Approximate location from IP via Geocoder + local GeoLite2 (see geocoder.rb).
Ahoy.geocode = GEOIP_DATABASE.file?

# Hash stored IPs; geocoding runs on the request IP before persistence.
Ahoy.mask_ips = true

# Bot traffic is excluded from visits/events by default in recent Ahoy versions.
Ahoy.exclude_method = lambda do |controller, request|
  request.user_agent.to_s.match?(/bot|crawl|spider|slurp/i)
end
