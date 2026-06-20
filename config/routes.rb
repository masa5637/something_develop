Rails.application.routes.draw do
  get 'cards/index'
  get 'cards/new'
  get 'cards/create'
  get 'cards/edit'
  get 'cards/update'
  get 'cards/destroy'
  devise_for :users
  get 'home/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  root "home#index"

  get  '/login',  to: 'sessions#new'
  post '/login',  to: 'sessions#create'

  resources :battle, only: [:show]

  resources :lobby, only: [:index]

  resources :cards

  resources :decks do
    member do
      post "add_card/:card_id", action: :add_card, as: :add_card
      delete "remove_card/:card_id", action: :remove_card, as: :remove_card
    end
  end
end
