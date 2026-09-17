module Api
  module Admin
    class TeamController < BaseController
      before_action :require_admin!

      def create
        b = json_body
        member = TeamMember.create!(
          order: b["order"].to_i.nonzero? || 99,
          name: b["name"].to_s,
          role: b["role"].to_s,
          bio: b["bio"].to_s,
          image_url: b["imageUrl"].to_s
        )
        render json: member.to_api
      end

      def update
        member = TeamMember.find(params[:id])
        b = json_body
        member.order = b["order"].to_i if b.key?("order")
        member.name = b["name"] if b.key?("name")
        member.role = b["role"] if b.key?("role")
        member.bio = b["bio"] if b.key?("bio")
        member.image_url = b["imageUrl"] if b.key?("imageUrl")
        member.save!
        render json: member.to_api
      end

      def destroy
        TeamMember.find(params[:id]).destroy!
        render json: { success: true }
      end
    end
  end
end
