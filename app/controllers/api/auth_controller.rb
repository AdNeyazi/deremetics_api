module Api
  class AuthController < BaseController
    def register
      body = json_body
      email = body["email"].to_s.downcase.strip
      if email.blank? || body["password"].blank? || body["name"].blank?
        return render json: { error: "name, email and password are required" }, status: :bad_request
      end
      if User.exists?(email: email)
        return render json: { error: "Email already registered" }, status: :conflict
      end

      user = User.create!(
        email: email,
        name: body["name"],
        role: "user",
        password: body["password"],
        active: true
      )
      record_event("signup", "/signup", body["session_id"], user.id)
      set_auth_cookie(response, user)
      render json: { user: user.to_api }
    end

    def login
      body = json_body
      email = body["email"].to_s.downcase.strip
      user = User.find_by(email: email)
      unless user&.authenticate(body["password"].to_s)
        return render json: { error: "Invalid email or password" }, status: :unauthorized
      end
      if user.active == false
        return render json: { error: "Account is deactivated" }, status: :forbidden
      end

      record_event("login", "/login", body["session_id"], user.id)
      set_auth_cookie(response, user)
      render json: { user: user.to_api }
    end

    def logout
      clear_auth_cookie(response)
      render json: { success: true }
    end

    def me
      unless current_auth
        return render json: { user: nil }
      end
      user = User.find_by(id: current_auth[:id])
      render json: { user: user ? user.to_api : nil }
    end

    private

    def record_event(event_type, page, session_id, user_id)
      AnalyticsEvent.create!(
        event_type: event_type,
        page: page,
        metadata: {},
        session_id: session_id,
        user_id: user_id,
        timestamp: Time.current
      )
    end
  end
end
