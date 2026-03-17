Rails.application.routes.draw do
  devise_for :users

  root "pages#home"

  resources :friendships, only: [:create, :destroy] do
  member do
    patch :accept
    patch :decline
    end
  end

  resources :profiles, only: [:show]

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

  resources :recommendations, only: [:new, :create, :index]

  post "recommendations/results", to: "recommendations#results"


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get "surprise",     to: "movies#surprise"
  get "recommended",  to: "movies#recommended"
  get "welcome", to: "pages#welcome"

  resources :historics, only: [:index, :destroy] do
    resources :comments, only: [:create, :destroy]
    collection do
      get :films
      get :series
    end
  end

  resources :communities, only: [:index]
  get "community", to: "communities#index"

  get "calendar", to: "pages#calendar"

  get "up" => "rails/health#show", as: :rails_health_check

  match "/404", to: "errors#not_found",              via: :all
  match "/500", to: "errors#internal_server_error",  via: :all
end
