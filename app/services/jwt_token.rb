class JwtToken
  class << self
    def secret
      ENV.fetch("JWT_SECRET", "dev-secret-change-me")
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
      payload, = JWT.decode(token, secret, true, algorithm: "HS256")
      payload
    rescue JWT::DecodeError
      nil
    end
  end
end
