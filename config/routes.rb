Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :users, only: :new, path: "", path_names: { new: "sign-up" }
  resources :users, only: :create
  resources :sessions, only: :new, path: "", path_names: { new: "login" }
  controller :sessions do
    post "login" => :create
    get "logout" => :destroy
  end

  resources :email_address_verifications, only: [ :show ], param: :token do
    post "resend", on: :collection
  end

  root "meals#index", via: :all

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
