class Faq < ApplicationRecord
  include ApiJson

  self.primary_key = "id"

  before_validation :assign_id, on: :create

  def to_api
    {
      id: id,
      order: order,
      question: question,
      answer: answer
    }
  end

  private

  def assign_id
    self.id ||= SecureRandom.uuid
  end
end
