class Api::SessionsController < DeviseController
  respond_to :json
  
  def create 
    if params[:email].blank?
      render :json => { :message => "Missing login parameters" }, :success => false, :status => 422
      return
    end
    
    user = User.find_for_database_authentication(:email => params[:email])
    return invalid_login_attempt unless user
    
    if user.valid_password?(params[:password])
      user.ensure_authentication_token!
      render :json => { :email => user.email, :auth_token => user.authentication_token }.to_json, :success => true, :status => 201
    else
      invalid_login_attempt
    end
  end
  
  def destroy
    if params[:auth_token].blank?
      render :json => { :message => "Missing authentication token" }, :success => false, :status => 422
      return
    end
    
    user = User.find_by_authentication_token(params[:auth_token])
    return invalid_login_attempt unless user
    
    user.reset_authentication_token!
    render :json => { :message => "Session deleted" }, :success => true, :status => 201
  end

protected

  def invalid_login_attempt
    warden.custom_failure!
    render :json => { :message => "Error with your authentication" }, :success => false, :status => 401
  end
  
end
