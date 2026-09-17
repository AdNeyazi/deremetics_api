module Api
  class DiagnosticConsultationsController < BaseController
    def create
      body = json_body
      if body["fullName"].blank? || body["phone"].blank? || !body["consent"]
        return render json: { error: "fullName, phone and consent are required" }, status: :bad_request
      end

      auth = current_auth
      submission = DiagnosticConsultation.create!(
        full_name: body["fullName"],
        email: body["email"].to_s,
        phone: body["phone"],
        address: body["address"].to_s,
        blood_group: body["bloodGroup"].to_s,
        allergies: body["allergies"].to_s,
        current_routine: body["currentRoutine"].to_s,
        report_file_ids: body["reportFileIds"].is_a?(Array) ? body["reportFileIds"] : [],
        face_photo_file_ids: body["facePhotoFileIds"].is_a?(Array) ? body["facePhotoFileIds"] : [],
        consent: true,
        status: "New",
        user_id: auth ? auth[:id] : nil
      )
      render json: { success: true, id: submission.id }
    end
  end
end
