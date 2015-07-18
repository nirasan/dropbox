Rails.application.routes.draw do

  root to: 'nodes#index'

  devise_for :users

  resources :nodes, only: [:index, :create, :edit, :update, :destroy] do
    collection do
      get :search
    end
    member do
      get :new_file
      get :new_folder
      get :list
      get :download
      post :copy
      get :move_folder_list
      post :move
    end
  end

  resources :event_logs, only: [:index]

end
