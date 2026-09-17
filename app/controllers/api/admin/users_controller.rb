module Api
  module Admin
    class UsersController < BaseController
      before_action :require_admin!

      def index
        users = User.order(created_at: :desc)
        render json: users.map(&:to_api)
      end

      def update
        user = User.find(params[:id])
        user.active = json_body["active"] if json_body.key?("active")
        user.save!
        render json: user.to_api
      end
    end
  end
end
