class Api::SessionsController < ApplicationController
  #include Devise::Controllers::InternalHelpers
  
  respond_to :json
  prepend_before_filter :require_no_authentication, :only => [:create]
end
