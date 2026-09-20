class TeamMember < ApplicationRecord
  include ApiJson

  self.primary_key = "id"

  before_validation :assign_id, on: :create

  validates :name, presence: true, length: { maximum: 200 }
  validates :role, length: { maximum: 200 }
  validates :bio, length: { maximum: 2000 }
  validates :image_url, length: { maximum: 2048 },
                        format: { with: %r{\Ahttps?://\S+\z}i, message: "must be an http(s) URL" },
                        allow_blank: true

  def to_api
    {
      id: id,
      order: order,
      name: name,
      role: role,
      bio: bio,
      imageUrl: image_url
    }
  end

  private

  def assign_id
    self.id ||= SecureRandom.uuid
  end
end
