class Category < ApplicationRecord
  include ApiJson

  self.primary_key = "id"

  before_validation :assign_id, on: :create

  def to_api
    {
      id: id,
      key: key,
      order: order,
      label: label,
      introTitle: intro_title,
      introText: intro_text
    }
  end

  private

  def assign_id
    self.id ||= SecureRandom.uuid
  end
end
