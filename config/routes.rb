Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    get "/", to: "root#show"
    get "/root", to: "root#show"

    post "auth/register", to: "auth#register"
    post "auth/login", to: "auth#login"
    post "auth/logout", to: "auth#logout"
    get "auth/me", to: "auth#me"

    get "categories", to: "categories#index"
    get "content", to: "content#show"
    get "products", to: "products#index"
    get "team", to: "team#index"
    get "faqs", to: "faqs#index"
    get "packages", to: "packages#index"

    post "consultation", to: "consultations#create"
    post "analytics/event", to: "analytics_events#create"
    post "upload/chunk", to: "uploads#chunk"
    post "upload/complete", to: "uploads#complete"
    post "diagnostic-consultation", to: "diagnostic_consultations#create"

    namespace :admin do
      post "products", to: "products#create"
      put "products/:id", to: "products#update"
      delete "products/:id", to: "products#destroy"

      put "categories/:id", to: "categories#update"
      put "content", to: "content#update"

      post "team", to: "team#create"
      put "team/:id", to: "team#update"
      delete "team/:id", to: "team#destroy"

      post "faqs", to: "faqs#create"
      put "faqs/:id", to: "faqs#update"
      delete "faqs/:id", to: "faqs#destroy"

      post "packages", to: "packages#create"
      put "packages/:id", to: "packages#update"
      delete "packages/:id", to: "packages#destroy"

      get "diagnostic-consultations", to: "diagnostic_consultations#index"
      put "diagnostic-consultations/:id", to: "diagnostic_consultations#update"

      get "secure-file/:id", to: "secure_files#show"

      get "users", to: "users#index"
      put "users/:id", to: "users#update"

      get "consultations", to: "consultations#index"
      get "analytics/overview", to: "analytics#overview"
    end
  end
end
