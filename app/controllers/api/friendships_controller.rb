class Api::FriendshipsController < ApplicationController
  respond_to :json
  
  before_filter :authenticate_api_user!
  
  def create
  end

  def destory
  end
end
