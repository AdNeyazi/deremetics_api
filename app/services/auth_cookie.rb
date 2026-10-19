class AuthCookie
  NAME = "access_token"

  class << self
    def set(response, token)
      response.set_cookie(NAME, cookie_options.merge(value: token))
    end

    def clear(response)
      response.set_cookie(NAME, cookie_options.merge(value: "", max_age: 0))
    end

    def cookie_options
      domain = ENV["COOKIE_DOMAIN"].presence

      same_site = if ENV["COOKIE_SAME_SITE"].present?
        ENV["COOKIE_SAME_SITE"].to_s.downcase.to_sym
      elsif Rails.env.development? || domain.present?
        :lax
      else
        # :lax is recommended for single-domain / reverse-proxied production deployments.
        # Set COOKIE_SAME_SITE=none in .env only when UI and API are on completely different root domains.
        :lax
      end

      secure = if ENV.key?("COOKIE_SECURE")
        ENV["COOKIE_SECURE"].to_s.downcase == "true"
      else
        !Rails.env.development? && !Rails.env.test?
      end

      base = {
        value: "",
        httponly: true,
        secure: secure,
        same_site: same_site,
        path: "/",
        max_age: 7.days.to_i
      }

      base[:domain] = domain if domain
      base
    end
  end
end
