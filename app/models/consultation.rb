class Consultation < ApplicationRecord
  include ApiJson

  self.primary_key = "id"

  before_validation :assign_id, on: :create
  before_validation :set_created_at, on: :create

  def to_api
    {
      id: id,
      name: name,
      phone: phone,
      email: email,
      tier: tier,
      message: message,
      createdAt: iso_time(created_at)
    }
  end

  private

  def assign_id
    self.id ||= SecureRandom.uuid
  end

  def set_created_at
    self.created_at ||= Time.current
  end
end
