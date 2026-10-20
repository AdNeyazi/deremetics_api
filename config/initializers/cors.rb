Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    allowed = ENV.fetch("FRONTEND_ORIGIN", "http://localhost:3000,https://dermetics.vercel.app,https://dermatics.vercel.app")
    origins allowed.split(",").map { |o| o.strip.chomp("/") }
    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: true,
      expose: %w[Content-Disposition]
  end
end
