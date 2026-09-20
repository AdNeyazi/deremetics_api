module Api
  class BaseController < ApplicationController
    include ActionController::Cookies

    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ArgumentError, with: :bad_request
    rescue_from JSON::ParserError, with: :invalid_json
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable
    rescue_from ActiveRecord::RecordNotUnique, with: :conflict

    before_action :verify_origin!
    before_action :require_json_body!

    def current_auth
      return @current_auth if defined?(@current_auth)

      payload = JwtToken.decode(cookies[AuthCookie::NAME])
      user = payload && User.find_by(id: payload["sub"])

      # Role and active status come from the database, not from the token.
      @current_auth = if user&.active
        { id: user.id, email: user.email, role: user.role, name: user.name }
      end
    end

    def require_admin!
      return if current_auth&.dig(:role) == "admin"

      render json: { error: "Unauthorized" }, status: :unauthorized
    end

    def json_body
      @json_body ||= begin
        data = if request.content_type.to_s.include?("application/json")
          JSON.parse(request.raw_post.presence || "{}")
        else
          request.request_parameters.presence || {}
        end
        raise ArgumentError, "Request body must be a JSON object" unless data.is_a?(Hash)

        data
      end
    end

    private

    SAFE_METHODS = %w[GET HEAD OPTIONS].freeze

    # Browsers always send an Origin header on cross-site POST/PUT/DELETE.
    # If it is present, it must be one of our frontends. If it is absent the
    # caller is not a browser (curl, server-to-server), and CSRF is a
    # browser-only attack, so it is allowed.
    def verify_origin!
      return if SAFE_METHODS.include?(request.request_method)

      origin = request.headers["Origin"].presence
      return if origin.nil?
      return if allowed_origins.include?(origin)

      render json: { error: "Forbidden origin" }, status: :forbidden
    end

    # A plain HTML form cannot send JSON, so a body that is not JSON is refused.
    def require_json_body!
      return if SAFE_METHODS.include?(request.request_method)
      return if request.content_length.to_i.zero?
      return if request.content_type.to_s.include?("application/json")

      render json: { error: "Content-Type must be application/json" }, status: :unsupported_media_type
    end

    def allowed_origins
      @allowed_origins ||= ENV.fetch("FRONTEND_ORIGIN", "http://localhost:3000")
                              .split(",").map { |o| o.strip.chomp("/") }
    end

    def not_found
      render json: { error: "Not found" }, status: :not_found
    end

    def bad_request(err)
      render json: { error: err.message }, status: :bad_request
    end

    def invalid_json
      render json: { error: "Invalid JSON" }, status: :bad_request
    end

    def unprocessable(err)
      render json: { error: err.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end

    def conflict
      render json: { error: "Already exists" }, status: :conflict
    end

    def set_auth_cookie(response, user)
      AuthCookie.set(response, JwtToken.encode(user))
    end

    def clear_auth_cookie(response)
      AuthCookie.clear(response)
    end
  end
end
