class Api::FriendshipsController < ApplicationController
  respond_to :json
  
  before_filter :authenticate_api_user!
  before_filter :ensure_friend_params
  
  def create
    unless current_user.friendships.find_by_friend_id(params[:friend_id]).nil?
      render :json => { :error => "That user is already your friend or has a pending request" }.to_json, 
             :success => false, 
             :status => 401
      return
    end
    
    @friendship1 = Friendship.build(:user_id => current_user.id, :friend_id => params[:friend_id], :status => "requested")
    @friendship2 = Friendship.build(:user_id => params[:friend_id], :friend_id => current_user.id, :status => "pending")
    
    begin
      ActiveRecord::Base.transactions do
        @friendship1.save!
        @friendship2.save!
      end
      render :json => { :message => "Friend request sucessful" }.to_json, :success => true, :status => 201
    rescue ActiveRecord::RecordInvalid => invalid
      render :json => { :message => "Friend records unable to save" }.to_json, :success => false, :status => 401
    end
  end

  def update
    if current_user.friendships.find_by_friend_id(params[:friend_id]).nil?
      render :json => { :error => "That user and friend do not have a friendship" }.to_json, 
             :success => false, 
             :status => 401
      return
    end
    
    @friendship1 = Friendship.find_by_user_id_and_friend_id(current_user.id, params[:friend_id])
    @friendship2 = Friendship.find_by_user_id_and_friend_id(params[:friend_id], current_user.id)
    
    begin
      ActiveRecord::Base.transactions do
        @friendship1.update_attributes!(:status => 'confirmed')
        @friendship2.update_attributes!(:status => 'confirmed')
      end
      render :json => { :message => "Friend confirmed" }.to_json, :success => true, :status => 201
    rescue ActiveRecord::RecordInvalid => invalid
      render :json => { :message => "Friend records unable to update" }.to_json, :success => false, :status => 401
    end
  end

  def destroy
    if current_user.friendships.find_by_friend_id(params[:friend_id]).nil?
      render :json => { :error => "That user and friend do not have a friendship" }.to_json, 
             :success => false, 
             :status => 401
      return
    end
    
    @friendship1 = Friendship.find_by_user_id_and_friend_id(current_user.id, params[:friend_id])
    @friendship2 = Friendship.find_by_user_id_and_friend_id(params[:friend_id], current_user.id)
    
    begin
      ActiveRecord::Base.transactions do
        @friendship1.destroy!
        @friendship2.destroy!
      end
      render :json => { :message => "Friendship destroyed" }.to_json, :success => true, :status => 201
    rescue
      render :json => { :message => "Friend records unable to delete" }.to_json, :success => false, :status => 401
    end
  end
  
protected

  def ensure_friend_params
    if params[:friend_id].blank?
      render :json => { :error => "No friend was supplied" }.to_json, :success => false, :status => 401
    elsif current_user.id == params[:friend_id] 
      render :json => { :error => "Cannot friend yourself" }.to_json, :success => false, :status => 401
    elsif User.find(params[:friend_id]).nil?
      render :json => { :error => "Friend does not exist" }.to_json, :success => false, :status => 401
    end
  end

end
