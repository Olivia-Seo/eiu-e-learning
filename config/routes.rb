Rails.application.routes.draw do
  
  #devise_for :users
  devise_for :users, :controllers => { :registrations => "users/registrations" , 
                                       omniauth_callbacks: 'users/omniauth_callbacks'}
  
  resources :enrollments do
    get :my_students, on: :collection
  end
  
  resources :courses do
    get :purchased, :pending_review, :created, :unapproved, on: :collection
    member do
      get :analytics
      patch :approve
      patch :unapprove
    end
    
    resources :lessons do
      resources :comments, except: [:index]
      put :sort
      member do
        delete :delete_video
      end
    end
    
    resources :enrollments, only: [:new, :create]
  end
  resources :youtube, only: :show
  resources :users, only: [:index, :edit, :show, :update]
  get 'home/index'
  get 'activity', to: 'home#activity'
  get 'analytics', to: 'home#analytics'
  
  namespace :charts do
    get 'users_per_day'
    get 'enrollments_per_day'
    get 'course_popularity'
    get 'money_makers'
  end
  
  root "home#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
