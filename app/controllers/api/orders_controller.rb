# frozen_string_literal: true

module Api
  class OrdersController < BaseController
    def create
      ship = json_body["shipping"] || {}
      if ship["name"].to_s.strip.blank? || ship["phone"].to_s.strip.blank? || ship["address"].to_s.strip.blank?
        return render json: { error: "Name, phone and address are required" }, status: :unprocessable_entity
      end
      if ship["pincode"].to_s.gsub(/\D/, "").length != 6
        return render json: { error: "Enter a valid 6-digit pincode" }, status: :unprocessable_entity
      end

      user = current_auth && User.find_by(id: current_auth[:id])
      order = OrderCheckout.call(user: user, body: json_body)
      render json: { success: true, order: order.to_api }, status: :created
    rescue ArgumentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Invalid coupon code" }, status: :unprocessable_entity
    end

    def index
      user = current_auth
      return render json: { error: "Login required" }, status: :unauthorized unless user

      orders = Order.where(user_id: user[:id]).order(created_at: :desc).limit(50)
      render json: orders.map(&:to_api)
    end

    def show
      user = current_auth
      return render json: { error: "Login required" }, status: :unauthorized unless user

      order = Order.find(params[:id])
      unless order.user_id == user[:id] || user[:role] == "admin"
        return render json: { error: "Not found" }, status: :not_found
      end
      render json: order.to_api
    end
  end
end
