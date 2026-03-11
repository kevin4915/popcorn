Rails.application.routes.draw do
  devise_for :users
  root "pages#home"
  resources :movies, only: [:index, :show] do
    member do
      post :swipe
    end
  end
  resources :historics, only: [:index]
  resources :communities, only: [:index]
  get "community", to: "communities#index"
  resources :historics, only: [:index] do
  resources :comments, only: [:create]
  end

  get "calendar", to: "pages#calendar"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
