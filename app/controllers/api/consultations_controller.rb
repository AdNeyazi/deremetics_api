module Api
  class ConsultationsController < BaseController
    def create
      body = json_body
      if body["name"].blank? || body["phone"].blank?
        return render json: { error: "name and phone are required" }, status: :bad_request
      end

      submission = Consultation.create!(
        name: body["name"],
        phone: body["phone"],
        email: body["email"].to_s,
        tier: body["tier"].to_s,
        message: body["message"].to_s
      )
      render json: { success: true, submission: submission.to_api }
    end
  end
end
