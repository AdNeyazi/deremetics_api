class User < ApplicationRecord
  include ApiJson

  self.primary_key = "id"

  has_secure_password

  before_validation :assign_id, on: :create
  before_validation :set_created_at, on: :create

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true
  validates :role, presence: true

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
