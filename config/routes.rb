SocialGym::Application.routes.draw do

  namespace :api do
    devise_for :users
  end
  
  root :to => 'home#index'
  
end
