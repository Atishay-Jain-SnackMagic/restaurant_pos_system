Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  controller :registration do
    get "sign-up" => :new
    post "register" => :create
  end

  controller :session do
    get "login" => :new
    post "login" => :create
    delete "logout" => :destroy
  end

  controller :users do
    get 'verify_email/:token', action: :verify_email, as: :verify_email
    get 'request_verification_email', action: :request_verification_email, as: :new_verification_email
    post 'resend_verification_email', action: :resend_verification_email, as: :resend_verification_email
  end

  resources :passwords, only: [ :edit, :new, :create, :update ], param: :token

  root "meals#index", via: :all
  resources :meals, only: :index

  namespace 'admin' do
    resources :ingredients, except: :show
    resources :locations do
      resources :inventory_locations, except: :destroy
    end
    resources :meals
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
