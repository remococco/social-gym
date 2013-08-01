SocialGym::Application.routes.draw do

  namespace :api do
    devise_for :users
    resource :friendships, :only => [:create, :update, :destroy]
  end
  
  root :to => 'home#index'
  
end
