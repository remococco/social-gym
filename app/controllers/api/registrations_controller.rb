class Api::RegistrationsController < ApplicationController
  respond_to :json
  
  def create
    user = User.new(user_params)
    
    if user.save
      render :json => { :email => user.email, :auth_token => user.authentication_token }.to_json, :status => 201
      return
    else
      warden.custom_failure!
      render :json=> user.errors, :status => 422
    end
  end
  
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
  
  private :user_params

end
