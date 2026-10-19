# frozen_string_literal: true

UploadService.ensure_dirs!

if Product.none?
  products = [
    { tier: "premium", tag: "The Universal Essentials", name: "Luminous Cellular Dew", description: "A weightless hydrating essence that revives dull skin with a dewy, lit-from-within radiance.", price: 140, image_url: "https://images.pexels.com/photos/29642374/pexels-photo-29642374.jpeg" },
    { tier: "premium", tag: "The Universal Essentials", name: "Velvet Barrier Cream", description: "A rich, restorative moisturiser that fortifies the skin barrier and locks in lasting comfort.", price: 195, image_url: "https://images.pexels.com/photos/29240451/pexels-photo-29240451.jpeg" },
    { tier: "premium", tag: "The Universal Essentials", name: "Pure Nectar Essence", description: "A silky botanical essence that preps and balances the complexion for deeper absorption.", price: 165, image_url: "https://images.unsplash.com/photo-1613803745799-ba6c10aace85" },
    { tier: "ultra", tag: "Precision Longevity", name: "Telomere Matrix Serum", description: "A cellular longevity serum engineered to defend against biological ageing at its source.", price: 380, image_url: "https://images.unsplash.com/photo-1631390179406-0bfe17e9f89d" },
    { tier: "ultra", tag: "Precision Longevity", name: "Platinum Neuro-Infusion", description: "A neuro-active infusion that calms reactivity while visibly firming and refining texture.", price: 450, image_url: "https://images.unsplash.com/photo-1576426863848-c21f53c60b19" },
    { tier: "ultra", tag: "Precision Longevity", name: "Chronobiology Night Balm", description: "A time-released overnight balm synchronised to the skin's nocturnal repair rhythm.", price: 420, image_url: "https://images.unsplash.com/photo-1545936761-c64b78657cb1" }
  ]
  products.each { |attrs| Product.create!(**attrs, variants: []) }
end

variant_demo = {
  "Velvet Barrier Cream" => [
    { "label" => "50 ml", "price" => 195, "imageUrl" => "" },
    { "label" => "100 ml", "price" => 320, "imageUrl" => "" }
  ],
  "Luminous Cellular Dew" => [
    { "label" => "30 ml", "price" => 140, "imageUrl" => "" },
    { "label" => "50 ml", "price" => 210, "imageUrl" => "" }
  ],
  "Platinum Neuro-Infusion" => [
    { "label" => "15 ml", "price" => 450, "imageUrl" => "" },
    { "label" => "30 ml", "price" => 820, "imageUrl" => "" }
  ]
}
variant_demo.each do |name, variants|
  product = Product.find_by(name: name)
  next unless product
  product.update!(variants: variants) if product.variants.blank?
end

unless Product.exists?(name: "Solar Veil Mineral Fluid")
  Product.create!(
    tier: "premium",
    tag: "The Universal Essentials",
    name: "Solar Veil Mineral Fluid",
    description: "A weightless mineral sunscreen that shields, primes and perfects — available across protection levels.",
    price: 95,
    image_url: "https://images.unsplash.com/photo-1556228578-8c89e6adf883?crop=entropy&cs=srgb&fm=jpg&q=85",
    variants: [
      { "label" => "SPF 30", "price" => 95, "imageUrl" => "" },
      { "label" => "SPF 50", "price" => 115, "imageUrl" => "" },
      { "label" => "SPF 50+ PA++++", "price" => 140, "imageUrl" => "" }
    ]
  )
end

# Full PDP demo content for premium hero SKU (DERMATICS placeholders — admin-editable)
solar = Product.find_by(name: "Solar Veil Mineral Fluid")
if solar
  img = solar.image_url
  related = Product.where(tier: "premium").where.not(id: solar.id).limit(3).pluck(:id)
  solar.update!(
    compare_at_price: 1499,
    variants: [
      { "label" => "SPF 30 · 50 ml", "price" => 999, "mrp" => 1199, "imageUrl" => "", "inStock" => true },
      { "label" => "SPF 50 · 50 ml", "price" => 1175, "mrp" => 1499, "imageUrl" => "", "inStock" => true },
      { "label" => "SPF 50+ PA++++ · 50 ml", "price" => 1299, "mrp" => 1599, "imageUrl" => "", "inStock" => true }
    ],
    pdp: {
      "highlightLine" => "[PLACEHOLDER] Replace with your highlight badge text in admin",
      "badge" => "",
      "dermatologicallyTested" => false,
      "subtitle" => "SPF 50 PA++++ · Very high sun protection · Tested for Indian skin · 50 ml",
      "currency" => "INR",
      "taxInclusive" => true,
      "media" => [
        { "type" => "image", "url" => img, "order" => 0 },
        { "type" => "image", "url" => "https://images.unsplash.com/photo-1556228720-195a672e8a03?crop=entropy&cs=srgb&fm=jpg&q=85", "order" => 1 },
        { "type" => "image", "url" => "https://images.unsplash.com/photo-1570194065650-d99fb4b38b17?crop=entropy&cs=srgb&fm=jpg&q=85", "order" => 2 }
      ],
      "formulatedFor" => [
        { "label" => "Photo-ageing protection" },
        { "label" => "Sensitive skin" },
        { "label" => "Oily & combination skin" },
        { "label" => "Dry & normal skin" },
        { "label" => "Acne-prone skin" },
        { "label" => "Water & sweat resistant up to 80 mins" }
      ],
      "freeFrom" => [
        { "label" => "No silicones" },
        { "label" => "No mineral oils" },
        { "label" => "No drying alcohol" },
        { "label" => "No fragrance" },
        { "label" => "Non-comedogenic" },
        { "label" => "Dermatologically tested" }
      ],
      "proTips" => [
        { "label" => "Apply as the final AM step, 15 minutes before sun" },
        { "label" => "Reapply every 2 hours for maximum protection" },
        { "label" => "UV damage happens on cloudy days too" },
        { "label" => "Wear indoors — UVA penetrates windows" }
      ],
      "trust" => { "freeShipping" => true, "cod" => true, "gift" => true },
      "guarantee" => {
        "title" => "100% Money Back Guarantee within 45 days",
        "body" => "[PLACEHOLDER] Your skin needs time — not shortcuts.\n\nFollow your DERMATICS ritual consistently for 45 days. After completing your journey, if you don’t love your results, you have 15 more days to claim your money back.\n\nReal change deserves real time."
      },
      "stats" => [],
      "blendMarquee" => {
        "title" => "[PLACEHOLDER] Your signature technology name",
        "descriptors" => ["Descriptor one", "Descriptor two", "Descriptor three"]
      },
      "heroBanner" => {
        "sectionHeading" => "[PLACEHOLDER] Section heading — replace in admin",
        "headline" => "[PLACEHOLDER] High-performance daily UV defence",
        "lines" => [
          "Sun contributes significantly to visible ageing",
          "Mineral + supportive actives for barrier comfort",
          "Built for Indian climate and skin tones"
        ],
        "desktopImage" => "https://images.unsplash.com/photo-1556228578-8c89e6adf883?crop=entropy&cs=srgb&fm=jpg&q=85",
        "mobileImage" => "https://images.unsplash.com/photo-1556228578-8c89e6adf883?crop=entropy&cs=srgb&fm=jpg&q=85"
      },
      "story" => {
        "image" => img,
        "title" => "Story behind the formula",
        "body" => "[PLACEHOLDER — admin editable]\n\nDERMATICS Solar Veil was developed in our formulation lab for daily wear in Indian light and humidity. Protection is what allows skin to keep moving forward without carrying unnecessary damage into the next day.\n\nReplace this story with your brand narrative, patents, and science notes from the dashboard."
      },
      "benefitBanners" => [
        {
          "desktopImage" => "https://images.unsplash.com/photo-1556228720-195a672e8a03?crop=entropy&cs=srgb&fm=jpg&q=85",
          "mobileImage" => "https://images.unsplash.com/photo-1556228720-195a672e8a03?crop=entropy&cs=srgb&fm=jpg&q=85",
          "alt" => "Lightweight invisible finish — placeholder",
          "order" => 0
        }
      ],
      "ingredients" => [
        { "name" => "Zinc Oxide", "role" => "Broad-spectrum mineral UV filter", "description" => "[PLACEHOLDER] Helps shield against UVA/UVB while remaining elegant on skin.", "imageUrl" => "", "researchUrl" => "" },
        { "name" => "Titanium Dioxide", "role" => "Photostable UVB defence", "description" => "[PLACEHOLDER] Complements mineral protection with photostable performance.", "imageUrl" => "", "researchUrl" => "" },
        { "name" => "Niacinamide", "role" => "Barrier support & tone clarity", "description" => "[PLACEHOLDER] Supports barrier comfort for daily wear.", "imageUrl" => "", "researchUrl" => "" },
        { "name" => "Ectoin", "role" => "Environmental stress shield", "description" => "[PLACEHOLDER] Helps skin cope with environmental stressors.", "imageUrl" => "", "researchUrl" => "" }
      ],
      "inciText" => "[PLACEHOLDER INCI — replace in admin]\nAqua, Zinc Oxide, Titanium Dioxide, Caprylic/Capric Triglyceride, Niacinamide, Ectoin, Glycerin, …",
      "infoTabs" => {
        "overview" => "An ultra-lightweight mineral fluid designed for daily broad-spectrum protection. Fast-absorbing finish with no white cast — comfortable under makeup and built for Indian skin and climate.\n\n[PLACEHOLDER] Expand with DERMATICS science claims from admin.",
        "applicationProtocol" => "AM: Cleanse → serum → moisturiser → Solar Veil.\nSpread evenly over face, neck and ears. Reapply every 2 hours, or after swimming, sweating or towel drying.",
        "moreDetails" => "Net content: 50 ml (varies by variant).\nStore in a cool, dry place away from sunlight.\nFor external use only. Patch test recommended. Avoid contact with eyes.\n\n[PLACEHOLDER] Add manufacturer / marketer details in admin."
      },
      "faqs" => [
        {
          "question" => "What makes this different from a regular sunscreen?",
          "answer" => "Solar Veil pairs mineral UV filters with barrier-supporting actives so daily sun defence also supports skin comfort and longevity — not just burn prevention. [PLACEHOLDER — edit in admin]",
          "order" => 0
        },
        {
          "question" => "Can I use this under makeup?",
          "answer" => "Yes. The lightweight, fast-absorbing texture layers comfortably under makeup. Allow it to settle for a minute before foundation.",
          "order" => 1
        },
        {
          "question" => "Do I need sunscreen indoors?",
          "answer" => "UVA can pass through windows. Daily use helps protect against cumulative exposure from commuting and time near windows.",
          "order" => 2
        }
      ],
      "eligibleCoupons" => [
        { "code" => "DERMA10", "label" => "DERMA10 — 10% off (demo)" },
        { "code" => "WELCOME5", "label" => "WELCOME5 — welcome offer (demo)" }
      ],
      "relatedProductIds" => related,
      "bundleItems" => related.first(1).map { |id| { "productId" => id, "variantLabel" => "" } },
      "seo" => {
        "title" => "Solar Veil Mineral Fluid SPF 50 · DERMATICS",
        "description" => "Replace with your product meta description in admin.",
        "ogImage" => img
      }
    }
  )
end

Product.find_each { |p| p.save! if p.slug.blank? }

site = SiteContent.find_by(key: "site")
if site
  updates = {}
  if Array(site.marquee_lines).blank?
    updates[:marquee_lines] = [
      "Welcome to DERMATICS",
      "Your skin, your formulation",
      "Haute couture dermatology"
    ]
  end
  updates[:whatsapp_number] = "919876543210" if site.whatsapp_number.blank?
  if site.respond_to?(:guarantee_days) && site.guarantee_days.to_i <= 0
    updates[:guarantee_days] = 45
  end
  if site.respond_to?(:brand_trust_headline) && site.brand_trust_headline.blank?
    updates[:brand_trust_headline] = "Dermatologist trusted"
    updates[:brand_trust_promise] = "Replace with your one-line brand promise in Website Content."
  end
  site.update!(updates) if updates.any?
end

if TeamMember.none?
  [
    { order: 1, name: "Aarav Mehta", role: "Founder", bio: "Visionary behind DERMATICS, redefining luxury skincare through science, craft and deep personalisation.", image_url: "https://images.unsplash.com/photo-1560250097-0b93528c311a?crop=entropy&cs=srgb&fm=jpg&q=85" },
    { order: 2, name: "Dr. Isabella Rossi", role: "Chief Dermatologist", bio: "Board-certified dermatologist with two decades diagnosing and designing bespoke clinical protocols.", image_url: "https://images.unsplash.com/photo-1580489944761-15a19d654956?crop=entropy&cs=srgb&fm=jpg&q=85" },
    { order: 3, name: "Rohan Kapoor", role: "Lead Cosmetic Chemist", bio: "Master formulator translating each diagnosis into a stable, elegant, high-performance compound.", image_url: "https://images.pexels.com/photos/37148308/pexels-photo-37148308.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940" },
    { order: 4, name: "Dr. Naomi Chen", role: "Chief Scientist", bio: "Leads the scientific board, validating every formulation against the latest longevity research.", image_url: "https://images.pexels.com/photos/27086922/pexels-photo-27086922.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940" }
  ].each { |attrs| TeamMember.create!(**attrs) }
end

if Faq.none?
  [
    { order: 1, question: "My Skin My Formulation kaise kaam karta hai?", answer: "Sabse pehle aap hamare dermatologist ke saath consultation book karte hain. Aapki skin ka poora analysis hota hai — skin type, concerns aur goals. Uske baad hamara scientific board aapke liye ek custom formula design karta hai, jo lab mein specially compound hota hai. Ye ek personalised solution hai, na ki koi ready-made product." },
    { order: 2, question: "Custom formulation ready hone mein kitna time lagta hai?", answer: "Consultation ke baad, scientific board review aur custom compounding mein aam taur par 7 se 10 working days lagte hain. Har batch haath se, chhote quantities mein banaya jaata hai taaki freshness aur potency maximum rahe. Ready hote hi aapke ghar tak safely deliver kiya jaata hai." },
    { order: 3, question: "Agar formulation mujhe suit nahi karti toh?", answer: "Bilkul tension mat lijiye — hamari Infinite Perfection Guarantee aapke saath hai. Agar result perfect nahi lage, toh hamari team aapki feedback lekar formula ko dobara refine karti hai, bina kisi extra cost ke. Perfection ek continuous loop hai, aur hum tab tak refine karte hain jab tak aap poori tarah satisfied na ho jaayein." }
  ].each { |attrs| Faq.create!(**attrs) }
end

if Category.none?
  [
    { key: "premium", order: 1, label: "Premium", intro_title: "The Universal Essentials", intro_text: "A refined foundation of everyday luxuries — timeless formulations crafted to hydrate, protect and reveal the skin's natural brilliance." },
    { key: "ultra", order: 2, label: "Ultra Premium", intro_title: "Precision Longevity", intro_text: "Advanced, science-led actives engineered to defend against ageing at the cellular level — for those who demand more from their ritual." },
    { key: "super", order: 3, label: "Super Ultra Premium Luxury", intro_title: "My Skin My Formulation", intro_text: "Customise Skin Care Solution For Skin Lovers" }
  ].each { |attrs| Category.create!(**attrs) }
end

unless SiteContent.exists?(key: "site")
  SiteContent.create!(
    key: "site",
    hero_title: "DERMATICS",
    hero_sub: "The Art & Science of Bespoke Skincare",
    flagship_title: "MY SKIN MY FORMULATION",
    flagship_sub: "Customise Skin Care Solution For Skin Lovers",
    what_title: "What is My Skin My Formulation?",
    what_text: "My Skin My Formulation is our flagship bespoke service where your skincare is created entirely around you. Instead of choosing from ready-made products, you receive a formulation designed from your own dermatological diagnosis — a single, precise solution compounded to match your skin's exact needs, concerns and goals.",
    why_title: "Why My Skin My Formulation?",
    why_text: "Because no two skins are the same. Generic products treat an average; a bespoke formulation treats you. By uniting dermatology, cosmetic chemistry and longevity science, we craft a ritual that evolves with your skin — delivering results that mass-market luxury simply cannot promise.",
    process: [
      { "n" => "01", "title" => "Book Dermatologist Consultation", "text" => "A one-on-one session where our dermatologist maps your skin type, concerns and goals in detail." },
      { "n" => "02", "title" => "Scientific Board Review", "text" => "Our scientific board reviews your diagnosis and architects a formula tailored precisely to your skin." },
      { "n" => "03", "title" => "Custom Compounding & Approval", "text" => "Your bespoke formula is hand-compounded in small batches and approved for potency and safety." },
      { "n" => "04", "title" => "Home Delivery & Evaluation", "text" => "Delivered to your door, followed by a structured evaluation to refine and perfect your results." }
    ],
    feedback_title: "Infinite Perfection Guarantee",
    feedback_text: "Aapki skin ki journey humari zimmedari hai. Agar aapko apni formulation perfect na lage, toh hum aapki feedback lekar use baar-baar refine karenge — bina kisi extra cost ke. Kyunki perfection ek destination nahi, ek continuous feedback loop hai, aur hum tab tak nahi rukte jab tak aapki skin bilkul perfect na ho jaaye.",
    footer_heading: "Ready For Your Bespoke Formulation?",
    footer_text: "Speak with our concierge and begin a skincare ritual designed entirely around you.",
    phone: "+91 98765 43210",
    marquee_lines: ["Welcome to DERMATICS", "Your skin, your formulation", "Haute couture dermatology"],
    whatsapp_number: "919876543210",
    guarantee_days: 45,
    trust_complimentary_gift: true,
    trust_free_shipping: true,
    trust_cod: true,
    brand_trust_headline: "Dermatologist trusted",
    brand_trust_promise: "Replace with your one-line brand promise in Website Content."
  )
end

if Package.none?
  [
    { order: 1, name: "Essential Formulation", price: 1200, description: "The perfect entry into bespoke skincare — a single custom formula built around your primary skin concern.", recommended: false, features: ["1 Dermatologist Consultation", "1 Reformulation Iteration", "Quarterly Delivery", "Personalized Skin Diagnostic Report", "Email Support"] },
    { order: 2, name: "Advanced Formulation", price: 2800, description: "A complete, evolving ritual — multiple formulas refined together as your skin transforms through the seasons.", recommended: true, features: ["3 Dermatologist Consultations", "3 Reformulation Iterations", "Monthly Delivery", "Advanced Diagnostic Report", "Priority Concierge Support", "Seasonal Formula Adjustments"] },
    { order: 3, name: "Elite Formulation", price: 5500, description: "The pinnacle of personalisation — unlimited refinement, a dedicated scientific team, and white-glove care.", recommended: false, features: ["Unlimited Consultations", "Unlimited Reformulations", "Bi-Weekly Delivery", "Comprehensive Longevity Report", "24/7 Dedicated Concierge", "Dedicated Scientific Board", "Annual In-Person Skin Review"] }
  ].each { |attrs| Package.create!(**attrs) }
end

admin_email = ENV.fetch("ADMIN_EMAIL", "admin@dermatics.com").downcase
unless User.exists?(email: admin_email)
  User.create!(
    email: admin_email,
    name: "Admin",
    role: "admin",
    password: ENV.fetch("ADMIN_PASSWORD", "AdminPass123!"),
    active: true
  )
end

unless Coupon.exists?(code: "DERMA10")
  Coupon.create!(
    code: "DERMA10",
    label: "10% off your ritual",
    discount_type: "percent",
    discount_value: 10,
    active: true
  )
end

puts "DERMATICS seeds complete."
