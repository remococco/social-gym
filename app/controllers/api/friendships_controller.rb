class Api::FriendshipsController < ApplicationController
  respond_to :json
  
  before_filter :authenticate_api_user!
  before_filter :ensure_friend_params
  
  def create
    unless current_api_user.friendships.find_by_friend_id(params[:friend_id]).nil?
      render :json => { :error => "That user is already your friend or has a pending request" }.to_json, 
             :success => false, 
             :status => 401
      return
    end
    
    friend = User.find(params[:friend_id])
    
    friendship1 = current_api_user.friendships.build(:friend_id => friend.id, :status => 'requested')
    friendship2 = friend.friendships.build(:friend_id => current_api_user.id, :status => 'pending')
    
    begin
      ActiveRecord::Base.transaction do
        friendship1.save!
        friendship2.save!
      end
      
      render :json => { :message => "Friend request sucessful" }.to_json, :success => true, :status => 201
    rescue ActiveRecord::RecordNotSaved
      render :json => { :error => "Friend records unable to save" }.to_json, :success => false, :status => 401
    end
  end

  def update
    if current_api_user.friendships.find_by_friend_id(params[:friend_id]).nil?
      render :json => { :error => "Cannot update a friendship that doesn't exist" }.to_json, 
             :success => false, 
             :status => 401
      return
    end
    
    @friendship1 = Friendship.find_by_user_id_and_friend_id(current_api_user.id, params[:friend_id])
    @friendship2 = Friendship.find_by_user_id_and_friend_id(params[:friend_id], current_api_user.id)
    
    begin
      ActiveRecord::Base.transaction do
        @friendship1.update_attributes!(:status => 'confirmed')
        @friendship2.update_attributes!(:status => 'confirmed')
      end
      render :json => { :message => "Friend confirmed" }.to_json, :success => true, :status => 201
    rescue ActiveRecord::RecordNotSaved
      render :json => { :error => "Friend records unable to update" }.to_json, :success => false, :status => 401
    end
  end

  def destroy
    if current_api_user.friendships.find_by_friend_id(params[:friend_id]).nil?
      render :json => { :error => "Cannot delete a user and friend without friendship" }.to_json, 
             :success => false, 
             :status => 401
      return
    end
    
    @friendship1 = Friendship.find_by_user_id_and_friend_id(current_api_user.id, params[:friend_id])
    @friendship2 = Friendship.find_by_user_id_and_friend_id(params[:friend_id], current_api_user.id)
    
    begin
      ActiveRecord::Base.transaction do
        @friendship1.destroy!
        @friendship2.destroy!
      end
      render :json => { :message => "Friendship destroyed" }.to_json, :success => true, :status => 201
    rescue ActiveRecord::RecordNotSaved
      render :json => { :error => "Friend records unable to delete" }.to_json, :success => false, :status => 401
    end
  end
  
protected

  def ensure_friend_params
    if params[:friend_id].blank?
      render :json => { :error => "No friend was supplied" }.to_json, :success => false, :status => 401
    elsif current_api_user.id == params[:friend_id].to_i
      render :json => { :error => "Cannot friend yourself" }.to_json, :success => false, :status => 401
    elsif User.find_by_id(params[:friend_id]).nil?
      render :json => { :error => "Friended user does not exist" }.to_json, :success => false, :status => 401
    end
  end

end
