Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "static_pages#homepage"

  get "static_pages/playground", to: "static_pages#playground", as: :playground
  get "static_pages/pricing", to: "static_pages#pricing", as: :pricing
  get "static_pages/documentation", to: "static_pages#documentation", as: :documentation
  get "static_pages/about", to: "static_pages#about", as: :about
end
