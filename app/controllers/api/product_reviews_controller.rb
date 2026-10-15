# frozen_string_literal: true

module Api
  class ProductReviewsController < BaseController
    def create
      product = Product.find_by_param!(params[:product_id])
      b = json_body
      user = current_auth && User.find_by(id: current_auth[:id])

      unless user
        return render json: { error: "Login required to write a review" }, status: :unauthorized
      end

      unless Order.user_purchased_product?(user.id, product.id)
        return render json: { error: "Only verified buyers can submit a review for this product" }, status: :forbidden
      end

      review = ProductReview.new(
        product_id: product.id,
        user_id: user.id,
        author_name: user.name.presence || user.email.to_s.split("@").first,
        rating: b["rating"].to_i,
        title: b["title"].to_s,
        body: b["body"].to_s,
        photos: Array(b["photos"]).map(&:to_s).first(5),
        status: "pending",
        verified_purchase: Order.user_purchased_product?(user.id, product.id)
      )
      review.save!
      render json: { success: true, review: review.to_api, message: "Review submitted for moderation" }, status: :created
    end
  end
end
