Rails.application.routes.draw do
  devise_for :users

  namespace :admin do
    resources :groups, only: [:index, :show] do
      resources :cycles, only: [:new, :create]
    end
  end

  resources :matches, only: [:index, :edit, :update]
  resources :leaderboards, only: [:index]
  root "pages#home"
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
