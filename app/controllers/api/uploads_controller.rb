module Api
  class UploadsController < BaseController
    MAX_REQUEST_BYTES = 4.megabytes # base64 chunk + JSON overhead

    before_action :limit_request_size

    rescue_from JSON::ParserError do
      render json: { error: "Invalid JSON" }, status: :bad_request
    end

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

    private

    def limit_request_size
      return if request.content_length.to_i <= MAX_REQUEST_BYTES

      render json: { error: "Request too large" }, status: 413
    end
  end
end
