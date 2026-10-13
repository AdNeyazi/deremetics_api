# Local MaxMind GeoLite2 lookup for Ahoy visit geocoding (no HTTP geo API per request).
if GEOIP_DATABASE.file?
  Geocoder.configure(
    ip_lookup: :geoip2,
    geoip2: { file: GEOIP_DATABASE.to_s, lib: "maxminddb" },
    cache: Rails.cache,
    cache_options: { expires_in: 24.hours }
  )
else
  Rails.application.config.after_initialize do
    Rails.logger.warn(
      "[geocoder] GeoIP database missing at #{GEOIP_DATABASE}. " \
      "Download GeoLite2-City.mmdb (see SETUP.md). Visit geocoding will be skipped."
    )
  end
end
