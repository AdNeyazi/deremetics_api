class DiagnosticConsultation < ApplicationRecord
  include ApiJson

  self.primary_key = "id"

  before_validation :assign_id, on: :create
  before_validation :set_created_at, on: :create

  validates :full_name, presence: true, length: { maximum: 100 }
  validates :phone, presence: true, format: { with: /\A[0-9+\-\s()]{7,20}\z/, message: "is not a valid phone number" }
  validates :email, length: { maximum: 254 },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid email" },
                    allow_blank: true
  validates :address, length: { maximum: 500 }
  validates :blood_group, inclusion: { in: %w[A+ A- B+ B- AB+ AB- O+ O-] }, allow_blank: true
  validates :allergies, length: { maximum: 1000 }
  validates :current_routine, length: { maximum: 2000 }
  validates :status, length: { maximum: 50 }
  validate :file_id_lists_limit

  def file_id_lists_limit
    [ :report_file_ids, :face_photo_file_ids ].each do |attr|
      list = self[attr]
      errors.add(attr, "has too many files") if list.is_a?(Array) && list.size > 10
    end
  end

  def to_api
    {
      id: id,
      fullName: full_name,
      email: email,
      phone: phone,
      address: address,
      bloodGroup: blood_group,
      allergies: allergies,
      currentRoutine: current_routine,
      reportFileIds: report_file_ids || [],
      facePhotoFileIds: face_photo_file_ids || [],
      consent: consent,
      status: status,
      userId: user_id,
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
