Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  resources :projects do
    member do
      get :export, :defaults => { :format => 'json' }
    end
    resources :items do
      get :near_me, on: :collection
      get :photo_links
    end
  end
  resources :photos
  resources :data_imports do
    post :re_import, on: :member
    get :edit_srid, on: :member
  end
end
