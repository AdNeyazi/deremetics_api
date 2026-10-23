# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

class Ga4MeasurementProtocolService
  GA_ENDPOINT = "https://www.google-analytics.com/mp/collect"
  GA_DEBUG_ENDPOINT = "https://www.google-analytics.com/debug/mp/collect"

  def self.measurement_id
    ENV["GA_MEASUREMENT_ID"].to_s.strip
  end

  def self.api_secret
    ENV["GA_API_SECRET"].to_s.strip
  end

  def self.enabled?
    measurement_id.present? && api_secret.present?
  end

  # Sends custom or standard event to GA4 via Measurement Protocol
  def self.send_event(client_id:, name:, params: {}, user_id: nil, debug: false)
    cid = client_id.presence || SecureRandom.uuid

    payload = {
      client_id: cid,
      events: [
        {
          name: name.to_s,
          params: params
        }
      ]
    }
    payload[:user_id] = user_id.to_s if user_id.present?

    unless enabled?
      Rails.logger.debug { "[GA4 Server Measurement Protocol (Inactive)] Event: #{name}, Payload: #{payload.to_json}" }
      return { success: false, reason: "GA4 Measurement ID or API Secret not configured" }
    end

    base_url = debug ? GA_DEBUG_ENDPOINT : GA_ENDPOINT
    uri = URI("#{base_url}?api_secret=#{URI.encode_www_form_component(api_secret)}&measurement_id=#{URI.encode_www_form_component(measurement_id)}")

    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req.body = payload.to_json

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 5
    http.open_timeout = 3

    res = http.request(req)
    Rails.logger.info { "[GA4 Server Measurement Protocol] #{name} sent (HTTP #{res.code})" }

    { success: res.is_a?(Net::HTTPSuccess), status: res.code.to_i, body: res.body }
  rescue StandardError => e
    Rails.logger.warn { "[GA4 Server Measurement Protocol] Failed to send #{name}: #{e.message}" }
    { success: false, error: e.message }
  end

  # Tracks a confirmed order purchase
  def self.track_purchase(order, client_id: nil)
    return unless order

    items = if order.respond_to?(:order_items) && order.order_items.any?
      order.order_items.map do |item|
        {
          item_id: item.product_id.to_s,
          item_name: item.product_name,
          item_variant: item.variant_label.presence,
          price: item.unit_price.to_f,
          quantity: item.quantity.to_i
        }
      end
    else
      []
    end

    params = {
      transaction_id: order.id.to_s,
      value: order.total.to_f,
      currency: order.currency.presence || "INR",
      tax: 0.0,
      shipping: order.shipping.to_f,
      coupon: order.coupon_code.presence,
      payment_type: order.payment_method.presence || "cod",
      items: items
    }

    send_event(
      client_id: client_id,
      name: "purchase",
      params: params,
      user_id: order.user_id
    )
  end

  # Tracks a lead or consultation submission
  def self.track_lead(lead_type:, value: nil, client_id: nil, user_id: nil, metadata: {})
    params = {
      lead_type: lead_type,
      currency: "INR"
    }
    params[:value] = value.to_f if value.present?
    params.merge!(metadata)

    send_event(
      client_id: client_id,
      name: "generate_lead",
      params: params,
      user_id: user_id
    )
  end
end
