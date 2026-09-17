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
    phone: "+91 98765 43210"
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
    password: ENV.fetch("ADMIN_PASSWORD", "admin123"),
    active: true
  )
end

puts "DERMATICS seeds complete."
