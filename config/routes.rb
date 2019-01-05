Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      # Authentication related routes.
      get "auth/confirm-email/:token" => "auth#confirm_email"

      post "auth/login" => "auth#login"
      post "auth/deauthorize" => "auth#deauthorize"

      # Athlete related routes.
      get "athletes/:id/meta" => "meta#index"
      get "athletes/:id/best-efforts" => "best_efforts#index"
      get "athletes/:id/best-efforts/:distance" => "best_efforts#index"
      get "athletes/:id/best-efforts/:distance/top-one-by-year" => "best_efforts#top_one_by_year"
      get "athletes/:id/personal-bests" => "personal_bests#index"
      get "athletes/:id/personal-bests/:distance" => "personal_bests#index"
      get "athletes/:id/races" => "races#index"
      get "athletes/:id/races/:distance_or_year" => "races#index"

      post "athletes/:id/submit-email" => "athletes#submit_email" # set the email address that user has entered.
      post "athletes/:id/fetch-latest" => "athletes#fetch_latest"
      post "athletes/:id/save-profile" => "athletes#save_profile"
      post "athletes/:id/reset-profile" => "athletes#reset_profile"
      post "athletes/:id/subscribe-to-pro" => "athletes#subscribe_to_pro"

      # Static models.
      resources :best_effort_types, only: [:index]
      resources :faq_categories, only: [:index]
      resources :faqs, only: %i[index show]
      resources :race_distances, only: [:index]
      resources :subscription_plans, only: [:index]
      resources :workout_types, only: [:index]
    end
  end

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"
end
