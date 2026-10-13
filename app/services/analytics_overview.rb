class AnalyticsOverview
  # Ahoy may omit visitor_token on insert (API-only mode); fall back to visit_token.
  VISITOR_COUNT = "COUNT(DISTINCT COALESCE(NULLIF(visitor_token, ''), visit_token))".freeze

  def self.build
    new.build
  end

  def build
    now = Time.current
    range_start = now - 30.days
    start_of_today = now.beginning_of_day
    start_of_week = now - 7.days

    visits_scope = Ahoy::Visit.where(started_at: range_start..now)
    events_scope = Ahoy::Event.where(time: range_start..now)

    visitors_today = distinct_visitors(Ahoy::Visit.where(started_at: start_of_today..now))
    visitors_week = distinct_visitors(Ahoy::Visit.where(started_at: start_of_week..now))
    visitors_month = distinct_visitors(visits_scope)

    total_users = User.where(role: "user").count
    inquiries = events_scope.where(name: %w[inquiry cta_click]).count

    by_day = {}
    6.downto(0) do |i|
      d = (now - i.days).to_date
      by_day[d.iso8601] = Set.new
    end
    Ahoy::Visit.where(started_at: (now - 6.days).beginning_of_day..now)
               .pluck(:visitor_token, :started_at).each do |visitor_token, started_at|
      next if visitor_token.blank?

      key = started_at.to_date.iso8601
      by_day[key]&.add(visitor_token)
    end
    visitors_series = by_day.keys.sort.map { |k| { date: k[5..], visitors: by_day[k].size } }

    prod_counts = Hash.new(0)
    events_scope.where(name: %w[product_view inquiry]).find_each do |event|
      props = event.properties.is_a?(Hash) ? event.properties : {}
      name = props["name"].presence
      prod_counts[name] += 1 if name.present?
    end
    top_products = prod_counts.map { |name, count| { name: name, count: count } }
                              .sort_by { |h| -h[:count] }.first(6)

    tier_counts = Hash.new(0)
    events_scope.where(name: "tab_switch").find_each do |event|
      props = event.properties.is_a?(Hash) ? event.properties : {}
      tier = props["tier"].presence
      tier_counts[tier] += 1 if tier.present?
    end
    tier_interest = tier_counts.map { |tier, count| { tier: tier, count: count } }

    page_views = events_scope.where(name: "page_view").count
    funnel = {
      visits: page_views,
      productViews: events_scope.where(name: "product_view").count,
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
      funnel: funnel,
      visitorLocations: visitor_locations(visits_scope)
    }
  end

  private

  def distinct_visitors(scope)
    scope.where.not(visit_token: [nil, ""]).distinct.count(Arel.sql("COALESCE(NULLIF(visitor_token, ''), visit_token)"))
  end

  def visitor_locations(visits_scope)
    located = visits_scope.where.not(country: [nil, ""])

    top_countries = located.group(:country)
                           .order(Arel.sql("#{VISITOR_COUNT} DESC"))
                           .limit(15)
                           .pluck(Arel.sql("country"), Arel.sql(VISITOR_COUNT))
                           .map { |country, visitors| { country: country, visitors: visitors } }

    top_cities = []
    top_cities.concat(
      located.where.not(city: [nil, ""])
             .group(:country, :region, :city)
             .order(Arel.sql("#{VISITOR_COUNT} DESC"))
             .limit(15)
             .pluck(:country, :region, :city, Arel.sql(VISITOR_COUNT))
             .map { |country, region, city, visitors| { country: country, region: region, city: city, visitors: visitors } }
    )

    located.where(city: [nil, ""]).where.not(region: [nil, ""])
           .group(:country, :region)
           .order(Arel.sql("#{VISITOR_COUNT} DESC"))
           .limit(10)
           .pluck(:country, :region, Arel.sql(VISITOR_COUNT))
           .each do |country, region, visitors|
      top_cities << { country: country, region: region, city: "—", visitors: visitors }
    end

    located.where(city: [nil, ""]).where(region: [nil, ""])
           .group(:country)
           .order(Arel.sql("#{VISITOR_COUNT} DESC"))
           .limit(10)
           .pluck(Arel.sql("country"), Arel.sql(VISITOR_COUNT))
           .each do |country, visitors|
      top_cities << {
        country: country,
        region: "—",
        city: "Approximate (city unknown)",
        visitors: visitors
      }
    end

    top_cities = top_cities.sort_by { |row| -row[:visitors] }.first(15)

    { topCountries: top_countries, topCities: top_cities }
  end
end
