# frozen_string_literal: true

class OrderCheckout
  FREE_SHIPPING_THRESHOLD = 999

  def self.call(user:, body:)
    items_raw = Array(body["items"])
    raise ArgumentError, "Cart is empty" if items_raw.empty?

    lines = items_raw.map { |row| resolve_line(row) }
    subtotal = lines.sum { |l| l[:line_total] }

    discount = 0.to_d
    coupon_code = body["couponCode"].to_s.strip.upcase
    if coupon_code.present?
      coupon = Coupon.find_valid!(coupon_code)
      applied = coupon.apply_to(subtotal)
      discount = applied[:discount]
      subtotal_after = applied[:total]
    else
      subtotal_after = subtotal
    end

    shipping = subtotal_after >= FREE_SHIPPING_THRESHOLD ? 0.to_d : 49.to_d
    total = (subtotal_after + shipping).round(2)

    ship = body["shipping"] || {}
    payment_method = body["paymentMethod"].to_s
    payment_method = "cod" unless Order::PAYMENT_METHODS.include?(payment_method)

    test_mode = ENV.fetch("PAYMENT_MODE", "test") == "test"
    status = if payment_method == "cod"
      "paid"
    elsif test_mode
      "paid"
    else
      "pending"
    end

    order = Order.new(
      user_id: user&.id,
      status: status,
      payment_method: payment_method,
      payment_provider: payment_method == "online" ? "razorpay_stub" : "",
      coupon_code: coupon_code,
      referral_code: body["referralCode"].to_s.strip.first(64),
      subtotal: subtotal,
      discount: discount,
      shipping: shipping,
      total: total,
      currency: "INR",
      customer_name: ship["name"].to_s.strip,
      customer_email: ship["email"].to_s.strip,
      customer_phone: ship["phone"].to_s.gsub(/\D/, "").first(15),
      shipping_address: ship["address"].to_s.strip,
      shipping_city: ship["city"].to_s.strip,
      shipping_state: ship["state"].to_s.strip,
      shipping_pincode: ship["pincode"].to_s.gsub(/\D/, "").first(6)
    )
    order.save!

    lines.each do |l|
      OrderItem.create!(
        order_id: order.id,
        product_id: l[:product_id],
        product_name: l[:name],
        variant_label: l[:variant_label],
        quantity: l[:quantity],
        unit_price: l[:unit_price],
        line_total: l[:line_total]
      )
    end

    order
  end

  def self.resolve_line(row)
    product = Product.find(row["productId"] || row["product_id"])
    label = (row["variantLabel"] || row["variant_label"] || "").to_s
    qty = (row["quantity"] || 1).to_i.clamp(1, 99)

    variants = product.normalized_variants_api
    variant = if label.present?
      variants.find { |v| v[:label] == label } || variants.first
    else
      variants.first
    end
    unit = (variant&.dig(:price) || product.price).to_d
    in_stock = variant ? variant[:inStock] : true
    raise ArgumentError, "#{product.name} is out of stock" if in_stock == false

    {
      product_id: product.id,
      name: product.name,
      variant_label: label,
      quantity: qty,
      unit_price: unit,
      line_total: (unit * qty).round(2)
    }
  end
end
