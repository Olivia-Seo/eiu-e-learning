Rails.application.routes.draw do
  devise_for :users
  resources :courses
  resources :users, only: [:index]
  get 'home/index'
  root "home#index"
  get 'home/index'
  get 'home/privacy_policy'
  get "privacy_policy", to: "home#privacy_policy"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
