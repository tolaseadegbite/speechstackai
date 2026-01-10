Rails.application.routes.draw do
  # ==========================================
  # 1. System & Engines
  # ==========================================
  mount MissionControl::Jobs::Engine, at: "/jobs"
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Health check & PWA
  get "up" => "rails/health#show", as: :rails_health_check
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "serviceworker.js" => "rails/pwa#service_worker", as: :pwa_service_worker


  # ==========================================
  # 2. Marketing & Static Pages
  # ==========================================
  root "static_pages#homepage"

  get "/pricing",       to: "static_pages#pricing"
  get "/documentation", to: "static_pages#documentation"
  get "/about",         to: "static_pages#about"
  get "/playground",    to: "static_pages#playground"


  # ==========================================
  # 3. Core App Features (Audio Generation)
  # ==========================================

  # Global History & Shared Actions (Delete, S3 URL)
  resources :generated_audio_clips, only: [ :index, :destroy ] do
    get :audio_url, on: :member
  end

  # resources :pdf_extractions, only: [ :create ]
  resources :document_extractions, only: [ :create ]

  # Specific Features (Using the new Controller Structure)
  # Note: I used 'scope' to avoid repeating 'module: :audio_generations' 3 times
  scope module: :audio_generations do
    resources :text_to_speeches,  only: [ :index, :create ], path: "text-to-speech"
    resources :voice_conversions, only: [ :index, :create ], path: "voice-changer"
    resources :sound_effects,     only: [ :index, :create ], path: "sound-effects"
  end

  resources :feedbacks
  resources :voices do
    get :audio_url, on: :member
  end
  resource :dashboard, only: [ :show ]
  get "/settings", to: "home#index"


  # ==========================================
  # 4. Authentication & Identity
  # ==========================================
  get  "sign_in",  to: "sessions#new"
  post "sign_in",  to: "sessions#create"
  get  "sign_up",  to: "registrations#new"
  post "sign_up",  to: "registrations#create"

  resources :sessions, only: [ :index, :show, :destroy ]
  resource  :session # Current session management
  resource  :password, only: [ :edit, :update ]
  resources :passwords, param: :token
  resource  :invitation, only: [ :new, :create ]

  # OAuth / Masquerading
  get  "/auth/failure",            to: "sessions/omniauth#failure"
  get  "/auth/:provider/callback", to: "sessions/omniauth#create"
  post "/auth/:provider/callback", to: "sessions/omniauth#create"
  post "users/:user_id/masquerade", to: "masquerades#create", as: :user_masquerade

  namespace :sessions do
    resource :passwordless, only: [ :new, :edit, :create ]
    resource :sudo, only: [ :new, :create ]
  end

  namespace :identity do
    resource :email,              only: [ :edit, :update ]
    resource :name,               only: [ :edit, :update ]
    resource :email_verification, only: [ :show, :create ]
    resource :password_reset,     only: [ :new, :edit, :create, :update ]
  end

  namespace :authentications do
    resources :events, only: :index
  end

  namespace :two_factor_authentication do
    namespace :challenge do
      resource :security_keys,  only: [ :new, :create ]
      resource :totp,           only: [ :new, :create ]
      resource :recovery_codes, only: [ :new, :create ]
    end
    namespace :profile do
      resources :security_keys
      resource  :totp,           only: [ :new, :create, :update ]
      resources :recovery_codes, only: [ :index, :create ]
    end
  end

  # ADMIN NAMESPACE
  # Accessible only to users with admin: true
  namespace :admin do
    root "dashboard#index"

    resources :users, only: [ :index, :show, :edit, :update ]
    resources :voices
    resources :generated_audio_clips, only: [ :index, :destroy ]
  end
end
