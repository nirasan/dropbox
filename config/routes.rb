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
      # share_userはModel構造的にもNodeの子なので別にした方が良さそう
      # 例) resources :share_users, only: [:new, :create, :destroy]
      # > create_share_user, destroy_share_user は意味的に share_user_controller に分けたほうがいいですね。
      get :share_setting
      post :change_share_setting
      post :create_share_user
      post :destroy_share_user
    end
  end
  get '/share/:share_path(/:node_id)', to: 'nodes#share', as: 'share'

  resources :event_logs, only: [:index]
  
  resources :share_users

end
