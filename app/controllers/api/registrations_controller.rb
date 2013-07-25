class Api::RegistrationsController < ApplicationController
  respond_to :json
  
  def create
    user = User.new(user_params)
    
    if user.save
      user.ensure_authentication_token!
      render :json => { :email => user.email, :auth_token => user.authentication_token }.to_json, :success => true, :status => 201
      return
    else
      warden.custom_failure!
      render :json => { :error => "Cannot create user with given credentials" }.to_json, :success => false, :status => 422
    end
  end
  
private

  def user_params
    params.require(:user).permit(:email, :password)
  end

end
