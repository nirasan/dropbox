Rails.application.routes.draw do

  root to: 'nodes#index'

  devise_for :users

  resources :nodes do
    collection do
      get :search
    end
    member do
      get :new_file
      get :new_folder
      get :list
      get :download
      get :copy
    end
  end

  resources :event_logs, only: [:index]

end
