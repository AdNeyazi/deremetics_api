module Api
  module Admin
    class SecureFilesController < BaseController
      before_action :require_admin!

      def show
        meta = SecureFile.find(params[:id])
        unless File.exist?(meta.path)
          return render json: { error: "File missing" }, status: :not_found
        end

        send_file meta.path,
          type: meta.content_type,
          disposition: "inline",
          filename: meta.original_name
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end
    end
  end
end
