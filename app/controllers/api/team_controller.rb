module Api
  class TeamController < BaseController
    def index
      render json: TeamMember.order(:order).map(&:to_api)
    end
  end
end
