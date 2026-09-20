class JwtToken
  MIN_SECRET_LENGTH = 32

  class << self
    def secret
      @secret ||= begin
        value = ENV["JWT_SECRET"].to_s

        if Rails.env.production?
          raise "JWT_SECRET is not set" if value.blank?
          raise "JWT_SECRET must be at least #{MIN_SECRET_LENGTH} characters" if value.length < MIN_SECRET_LENGTH
        end

        value.presence || "dev-secret-change-me" # fallback only outside production
      end
    end

    def encode(user)
      payload = {
        sub: user.id,
        email: user.email,
        role: user.role,
        name: user.name,
        iat: Time.now.to_i,
        exp: 7.days.from_now.to_i
      }
      JWT.encode(payload, secret, "HS256")
    end

    def decode(token)
      return nil if token.blank?

      payload, = JWT.decode(token, secret, true, algorithm: "HS256")
      payload
    rescue JWT::DecodeError
      nil
    end
  end
end
