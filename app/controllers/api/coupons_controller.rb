# frozen_string_literal: true

module Api
  class CouponsController < BaseController
    def validate
      code = json_body["code"].to_s.strip.upcase
      subtotal = (json_body["subtotal"] || 0).to_f
      return render json: { error: "Enter a coupon code" }, status: :unprocessable_entity if code.blank?

      coupon = Coupon.active.find_by(code: code)
      unless coupon
        return render json: { valid: false, error: "Invalid or expired coupon" }, status: :unprocessable_entity
      end

      applied = coupon.apply_to(subtotal)
      render json: {
        valid: true,
        coupon: coupon.to_api,
        subtotal: subtotal,
        discount: applied[:discount].to_f,
        total: applied[:total].to_f
      }
    rescue ActiveRecord::RecordNotFound
      render json: { valid: false, error: "Invalid or expired coupon" }, status: :unprocessable_entity
    end
  end
end
