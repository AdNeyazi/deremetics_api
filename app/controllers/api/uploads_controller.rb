module Api
  class UploadsController < BaseController
    def chunk
      body = json_body
      if body["uploadId"].blank? || body["index"].nil? || body["data"].blank?
        return render json: { error: "uploadId, index and data required" }, status: :bad_request
      end

      UploadService.write_chunk(body["uploadId"], body["index"], body["data"])
      render json: { success: true, index: body["index"] }
    rescue ArgumentError => e
      render json: { error: e.message }, status: :bad_request
    end

    def complete
      body = json_body
      result = UploadService.complete(body["uploadId"], body["fileName"], body["contentType"])
      render json: result
    rescue ArgumentError => e
      render json: { error: e.message }, status: :bad_request
    end
  end
end
