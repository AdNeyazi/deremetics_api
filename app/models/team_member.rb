class TeamMember < ApplicationRecord
  include ApiJson

  self.primary_key = "id"

  before_validation :assign_id, on: :create

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
