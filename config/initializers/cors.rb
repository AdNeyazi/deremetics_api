Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    raw = ENV.fetch("FRONTEND_ORIGIN", "https://dermetics.vercel.app,http://localhost:3000")
    origins_list = raw.split(",").map do |entry|
      uri = URI.parse(entry.to_s.strip) rescue nil
      if uri && uri.scheme && uri.host
        port_part = (uri.port && ![80, 443].include?(uri.port)) ? ":#{uri.port}" : ""
        "#{uri.scheme}://#{uri.host}#{port_part}"
      else
        entry.to_s.strip.chomp("/")
      end
    end
    origins(*origins_list, %r{\Ahttps://[a-zA-Z0-9-]+\.vercel\.app\z})
    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: true,
      expose: %w[Content-Disposition]
  end
end
