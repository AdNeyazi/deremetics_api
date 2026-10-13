GEOIP_DATABASE = Rails.root.join(
  ENV.fetch("GEOIP_DATABASE_PATH", "vendor/geoip/GeoLite2-City.mmdb")
).freeze
