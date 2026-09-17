module Api
  class BaseController < ApplicationController
    include ActionController::Cookies

    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ArgumentError, with: :bad_request

    def current_auth
      return @current_auth if defined?(@current_auth)

      token = cookies[AuthCookie::NAME]
      payload = JwtToken.decode(token)
      @current_auth = payload ? {
        id: payload["sub"],
        email: payload["email"],
        role: payload["role"],
        name: payload["name"]
      } : nil
    end

    def require_admin!
      return if current_auth&.dig(:role) == "admin"

      render json: { error: "Unauthorized" }, status: :unauthorized
    end

    def json_body
      @json_body ||= begin
        if request.content_type.to_s.include?("application/json")
          JSON.parse(request.raw_post.presence || "{}")
        else
          request.request_parameters.presence || {}
        end
      end
    end

    private

    def not_found
      render json: { error: "Not found" }, status: :not_found
    end

    def bad_request(err)
      render json: { error: err.message }, status: :bad_request
    end

    def set_auth_cookie(response, user)
      AuthCookie.set(response, JwtToken.encode(user))
    end

    def clear_auth_cookie(response)
      AuthCookie.clear(response)
    end
  end
end
