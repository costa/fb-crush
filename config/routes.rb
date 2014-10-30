require 'user_authenticated_constraint'

FbCrush::Application.routes.draw do
  root :to => 'friends#index', :as => :rroot, :constraints => UserAuthenticatedConstraint.new
  root :to => 'home#index'
  get '/friends' => redirect('/'), :constraints => { format: :html }
  resources :friends, :only => [:index, :update]

  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
end
