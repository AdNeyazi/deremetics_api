# frozen_string_literal: true

module Api
  module Admin
    class ProductReviewsController < BaseController
      before_action :require_admin!

      def index
        scope = ProductReview.includes(:product).order(created_at: :desc)
        scope = scope.where(status: params[:status]) if params[:status].present?
        render json: scope.limit(200).map(&:to_admin_api)
      end

      def update
        review = ProductReview.find(params[:id])
        status = json_body["status"].to_s
        unless ProductReview::STATUSES.include?(status)
          return render json: { error: "Invalid status" }, status: :unprocessable_entity
        end

        review.update!(status: status)
        render json: review.to_admin_api
      end
    end
  end
end
