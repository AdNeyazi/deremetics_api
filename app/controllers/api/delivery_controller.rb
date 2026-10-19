# frozen_string_literal: true

module Api
  class DeliveryController < BaseController
    # Stub for courier APIs (Shiprocket / Delhivery / etc.)
    def check
      b = json_body
      pin = b["pincode"].to_s.gsub(/\D/, "")
      if pin.length != 6
        return render json: { error: "Enter a valid 6-digit pincode" }, status: :unprocessable_entity
      end

      # Deterministic stub: even last digit → COD available, ETA 3–5 days
      last = pin[-1].to_i
      days = 3 + (last % 3)
      eta = (Time.zone.today + days.days)
      render json: {
        pincode: pin,
        serviceable: true,
        codAvailable: last.even?,
        estimatedDays: days,
        estimatedDate: eta.strftime("%d %b %Y"),
        message: "Stub estimate — replace with courier API"
      }
    end
  end
end
