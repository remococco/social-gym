module DeviseHelper
  
  def devise_api_mappings
      request.env["devise.mapping"] = Devise.mappings[:api_user]
  end

end