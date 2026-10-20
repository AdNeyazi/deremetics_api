require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DermeticsApi
  class Application < Rails::Application
    config.api_only = true
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use Rack::Attack

    # Allow Vercel frontend, production domains, and preview subdomains
    config.hosts << "dermetics.vercel.app"
    config.hosts << "dermatics.vercel.app"
    config.hosts << "derma.crystalclearcraft.com"
    config.hosts << /.*\.vercel\.app\z/
    config.hosts << /.*\.crystalclearcraft\.com\z/

    if ENV["ALLOWED_HOSTS"].present?
      ENV["ALLOWED_HOSTS"].split(",").map(&:strip).reject(&:blank?).each do |h|
        config.hosts << h
      end
    end
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
