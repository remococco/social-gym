class Api::SessionsController < DeviseController
  respond_to :json
  before_filter :authenticate_api_user!, :except => [:create]
  #prepend_before_filter :require_no_authentication, :only => [:create]
  #before_filter :ensure_params_exist
  
  def create 
    user = User.find_for_database_authentication(:email => params[:email])
    return invalid_login_attempt unless user
    
    if user.valid_password?(params[:password])
      user.ensure_authentication_token!
      # TODO can this be sign_in user, or do we need to change to sign_in 'api_user, user'??
      sign_in 'user', user
      render :json => { :email => user.email, :auth_token => user.authentication_token }.to_json, :success => true, :status => 201
      return
    end
    invalid_login_attempt
  end
  
  def destroy
      user = User.find_by_authentication_token(params[:auth_token])
      user.reset_authentication_token!
      # TODO change this like above??
      sign_out user
      render :json => { :message => "Session deleted" }, :success => true, :status => 201
  end

protected
    
  def ensure_params_exist
    return unless params[:email].blank?
    render :json => { :message => "Missing login parameters" }, :success => false, :status => 422
  end

  def invalid_login_attempt
    warden.custom_failure!
    render :json => { :message => "Error with your login or password" }, :success => false, :status => 401
  end
  
end
