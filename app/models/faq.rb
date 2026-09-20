class Faq < ApplicationRecord
  include ApiJson

  self.primary_key = "id"

  before_validation :assign_id, on: :create

  validates :question, presence: true, length: { maximum: 500 }
  validates :answer, length: { maximum: 5000 }

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
