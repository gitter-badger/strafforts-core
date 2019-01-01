Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :best_effort_types, only: [:index]
      resources :faq_categories, only: [:index]
      resources :faqs, only: %i[index show]
      resources :race_distances, only: [:index]
      resources :subscription_plans, only: [:index]
      resources :workout_types, only: [:index]
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"
end
