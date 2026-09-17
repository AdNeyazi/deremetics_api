module Api
  module Admin
    class FaqsController < BaseController
      before_action :require_admin!

      def create
        b = json_body
        faq = Faq.create!(
          order: b["order"].to_i.nonzero? || 99,
          question: b["question"].to_s,
          answer: b["answer"].to_s
        )
        render json: faq.to_api
      end

      def update
        faq = Faq.find(params[:id])
        b = json_body
        faq.order = b["order"].to_i if b.key?("order")
        faq.question = b["question"] if b.key?("question")
        faq.answer = b["answer"] if b.key?("answer")
        faq.save!
        render json: faq.to_api
      end

      def destroy
        Faq.find(params[:id]).destroy!
        render json: { success: true }
      end
    end
  end
end
