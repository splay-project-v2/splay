Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'
  resources :home, only: [:index]
  resources :jobs, only: [:index, :destroy]
  resources :splayds, only: [:index, :show, :destroy]
  resources :users, only: [:new, :create]
  resources :sessions, only: [:new, :destroy]
end
