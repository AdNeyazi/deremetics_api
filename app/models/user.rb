class User < ApplicationRecord
  include ApiJson

  self.primary_key = "id"
  ROLES = %w[user admin].freeze

  has_secure_password

  before_validation :assign_id, on: :create
  before_validation :set_created_at, on: :create

  validates :email, length: { maximum: 254 },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid email" }
  validates :name, length: { maximum: 100 }
  validates :role, inclusion: { in: ROLES }
  validates :password, length: { minimum: 10, maximum: 72 }, allow_nil: true

  def to_api
    {
      id: id,
      email: email,
      name: name,
      role: role,
      active: active,
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
