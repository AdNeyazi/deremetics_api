module Api
  module Admin
    class SecureFilesController < BaseController
      before_action :require_admin!

      def show
        meta = SecureFile.find(params[:id])
        path = meta.path.to_s

        # Only serve files that live inside our uploads folder.
        inside_uploads = path.start_with?(UploadService.files_dir.to_s + "/")
        unless inside_uploads && File.file?(path)
          return render json: { error: "File missing" }, status: :not_found
        end

        # Only whitelisted types (PDF/images) may be shown inline.
        # Anything else (old uploads) is forced to download as a binary file.
        safe = UploadService::EXT_BY_TYPE.key?(meta.content_type)
        response.set_header("X-Content-Type-Options", "nosniff")

        send_file path,
          type: safe ? meta.content_type : "application/octet-stream",
          disposition: safe ? "inline" : "attachment",
          filename: meta.original_name
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end
    end
  end
end
