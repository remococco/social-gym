require 'spec_helper'

describe Api::FriendshipsController do
  
  describe 'friendship actions' do
    
    it "must contain 'friend_id'" do
    end
    
    it "should not allow the authenticated user to friend itself" do
    end
    
    it "should have a user for the given 'friend_id'" do
    end
    
  end
  
  describe 'user add friend' do
  
    it 'cannot add an already friended user' do
    end
    
    it "cannot add when both db transactions aren't successful" do
    end
  
  end
  
  describe 'user update friend' do
  
    it 'cannot change friend status if the users are not friends' do
    end
    
    it "cannot update when both db transactions aren't successful'" do
    end
  
  end
  
  describe 'user destroy friend' do
  
    it 'cannot destroy friend if the users are not friends' do
    end
    
    it "cannot destroy when both db transactions aren't successful'" do
    end
  
  end

end
