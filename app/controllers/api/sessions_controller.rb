class Api::SessionsController < DeviseController
  respond_to :json
  prepend_before_filter :require_no_authentication, :only => [:create]
  before_filter :ensure_params_exist
  
  def create 
    build_resource
    resource = User.find_for_database_authentication(:email => params[:email])
    return invalid_login_attempt unless resource
    
    if resource.valid_password?(params[:password])
      resource.ensure_authentication_token!
      sign_in 'user', resource
      render :json => { :email => resource.email, :auth_token => resource.authentication_token }.to_json, :success => true, :status => 201
      return
    end
    invalid_login_attempt
  end
  
  def destroy
      user = User.find_by_authentication_token(params[:auth_token])
      user.reset_authentication_token!
      sign_out user
      render :json => { :message => "Session deleted" }, :success => true, :status => 201
  end

protected
    
  def ensure_params_exist
    return unless params[:email].blank?
    render :json => { :message => "Missing user_login parameter" }, :success => false, :status => 422
  end

  def invalid_login_attempt
    warden.custom_failure!
    render :json => { :message => "Error with your login or password" }, :success => false, :status => 401
  end
  
end
