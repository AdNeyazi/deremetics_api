class AnalyticsOverview
  def self.build
    now = Time.current
    start = now - 30.days
    events = AnalyticsEvent.where(timestamp: start..now).to_a

    start_of_today = now.beginning_of_day
    start_of_week = now - 7.days
    start_of_month = now - 30.days

    page_views = events.select { |e| e.event_type == "page_view" }
    sessions_in = lambda do |from|
      page_views.select { |e| e.timestamp >= from && e.session_id.present? }.map(&:session_id).uniq.size
    end

    visitors_today = sessions_in.call(start_of_today)
    visitors_week = sessions_in.call(start_of_week)
    visitors_month = sessions_in.call(start_of_month)

    total_users = User.where(role: "user").count
    inquiries = events.count { |e| %w[inquiry cta_click].include?(e.event_type) }

    by_day = {}
    6.downto(0) do |i|
      d = (now - i.days).to_date
      by_day[d.iso8601] = Set.new
    end
    page_views.each do |e|
      key = e.timestamp.to_date.iso8601
      by_day[key]&.add(e.session_id) if e.session_id.present?
    end
    visitors_series = by_day.keys.sort.map do |k|
      { date: k[5..], visitors: by_day[k].size }
    end

    prod_counts = Hash.new(0)
    events.select { |e| %w[product_view inquiry].include?(e.event_type) }.each do |e|
      name = e.metadata.is_a?(Hash) ? (e.metadata["name"] || e.metadata[:name]) : nil
      prod_counts[name] += 1 if name.present?
    end
    top_products = prod_counts.map { |name, count| { name: name, count: count } }
                            .sort_by { |h| -h[:count] }.first(6)

    tier_counts = Hash.new(0)
    events.select { |e| e.event_type == "tab_switch" }.each do |e|
      tier = e.metadata.is_a?(Hash) ? (e.metadata["tier"] || e.metadata[:tier]) : nil
      tier_counts[tier] += 1 if tier.present?
    end
    tier_interest = tier_counts.map { |tier, count| { tier: tier, count: count } }

    funnel = {
      visits: page_views.size,
      productViews: events.count { |e| e.event_type == "product_view" },
      inquiries: inquiries
    }

    {
      stats: {
        visitorsToday: visitors_today,
        visitorsWeek: visitors_week,
        visitorsMonth: visitors_month,
        totalUsers: total_users,
        inquiries: inquiries
      },
      visitorsSeries: visitors_series,
      topProducts: top_products,
      tierInterest: tier_interest,
      funnel: funnel
    }
  end
end
