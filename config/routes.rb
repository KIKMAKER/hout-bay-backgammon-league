Rails.application.routes.draw do
  devise_for :users

  namespace :admin do
    resources :groups, only: %i[index show new create] do
      member do
        get :add_members
        post :assign_members
      end
      resources :cycles, only: %i[new create]
    end
    resources :cycles, only: %i[index show]
  end

  resources :matches, only: %i[index new create edit update]
  resources :leaderboards, only: %i[index] do
    collection do
      get :social
    end
  end
  root "pages#home"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
