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
      get :share_setting
      post :change_share_setting
      post :create_share_user
      post :destroy_share_user
    end
  end
  get '/share/:share_path', to: 'nodes#share', as: 'share'

  resources :event_logs, only: [:index]
  
  resources :share_users

end
