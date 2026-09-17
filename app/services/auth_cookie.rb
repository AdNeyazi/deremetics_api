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
      base = if Rails.env.development?
        {
          value: "",
          httponly: true,
          secure: false,
          same_site: :lax,
          path: "/",
          max_age: 7.days.to_i
        }
      else
        {
          value: "",
          httponly: true,
          secure: true,
          same_site: :none,
          path: "/",
          max_age: 7.days.to_i
        }
      end

      domain = ENV["COOKIE_DOMAIN"].presence
      base[:domain] = domain if domain
      base
    end
  end
end
