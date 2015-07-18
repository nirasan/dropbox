Rails.application.routes.draw do

  root to: 'nodes#index'

  devise_for :users

  resources :nodes do
    member do
      get :list
      get :download
    end
  end

end
