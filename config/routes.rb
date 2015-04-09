require 'user_authenticated_constraint'

FbCrush::Application.routes.draw do
  root :to => 'friends#app', :as => :rroot, :constraints => UserAuthenticatedConstraint.new
  root :to => 'home#index'
  get '/terms-und-policies', :to => 'home#terms', :as => :terms
  resources :friends, :only => [:index, :update]

  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'

  # XXX near future: post '/pusher/webhook' => 'pusher#webhook'
end
