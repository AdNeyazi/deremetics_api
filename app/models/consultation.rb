class Consultation < ApplicationRecord
  include ApiJson

  self.primary_key = "id"

  before_validation :assign_id, on: :create
  before_validation :set_created_at, on: :create

  validates :name, presence: true, length: { maximum: 100 }
  validates :phone, presence: true, format: { with: /\A[0-9+\-\s()]{7,20}\z/, message: "is not a valid phone number" }
  validates :email, length: { maximum: 254 },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid email" },
                    allow_blank: true
  validates :tier, length: { maximum: 50 }
  validates :message, length: { maximum: 2000 }

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
