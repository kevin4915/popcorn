Rails.application.routes.draw do
  devise_for :users

  root "pages#home"

  resources :movies, only: [:index, :show] do
    member do
      post :swipe
      post :add_to_list
      delete :remove_from_list
    end
    collection do
      get :search
    end
  end

  get "surprise", to: "movies#surprise"
  get "recommended", to: "movies#recommended"
  resources :historics, only: [:destroy] do
    collection do
      get :films
      get :series
    end
  end

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
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
end
