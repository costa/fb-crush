require 'user_authenticated_constraint'

FbCrush::Application.routes.draw do
  get '/', :to => 'friends#index', :as => :friends, :constraints => UserAuthenticatedConstraint.new
  root :to => 'home#index'
  resources :friends, :only => [:update]

  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
end
