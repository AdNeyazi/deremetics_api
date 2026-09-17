module Api
  module Admin
    class CategoriesController < BaseController
      before_action :require_admin!

      def update
        category = Category.find(params[:id])
        b = json_body
        category.label = b["label"] if b.key?("label")
        category.intro_title = b["introTitle"] if b.key?("introTitle")
        category.intro_text = b["introText"] if b.key?("introText")
        category.save!
        render json: category.to_api
      end
    end
  end
end
