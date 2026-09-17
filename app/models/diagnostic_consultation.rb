class DiagnosticConsultation < ApplicationRecord
  include ApiJson

  self.primary_key = "id"

  before_validation :assign_id, on: :create
  before_validation :set_created_at, on: :create

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
