require 'spec_helper'

describe Api::FriendshipsController do
  
  before :each do
    devise_api_mappings
  end
  
  describe 'friendship actions' do
    
    before :each do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
    
    it "must contain 'friend_id'" do
      post :create, { :auth_token => @user.authentication_token }
      contents = JSON.parse(response.body)
      
      expect(contents['error']).to match /No friend was supplied/
    end
    
    it "should not allow the authenticated user to friend itself" do
      post :create, { :auth_token => @user.authentication_token , :friend_id => @user.id }
      contents = JSON.parse(response.body)
      
      expect(contents['error']).to match /Cannot friend yourself/
    end
    
    it "should have a user for the given 'friend_id'" do
      post :create, { :auth_token => @user.authentication_token , :friend_id => 1000 }
      contents = JSON.parse(response.body)
      
      expect(contents['error']).to match /Friended user does not exist/
    end
    
  end
  
  describe 'user add friend' do
    
    before :each do
      @user1 = FactoryGirl.create(:user, :unique_email)
      @user2 = FactoryGirl.create(:user, :unique_email)
    end
    
    it 'should add a new friend' do
      post :create, { :auth_token => @user1.authentication_token, :friend_id => @user2 }

      success = response.success?
      expect(success).to be_true
    end
    
    it "should give new current user friendships a status of 'requested'" do
      action = expect { post :create, { :auth_token => @user1.authentication_token, :friend_id => @user2 } }
      action.to change(@user1.requested_friends, :count).by(1)
    end
    
    it "should give new friend friendships a status of 'pending'" do
      action = expect { post :create, { :auth_token => @user1.authentication_token, :friend_id => @user2 } }
      action.to change(@user2.pending_friends, :count).by(1)
    end
  
    it 'cannot add an already friended user' do
      @user1.friends << @user2
      @user2.friends << @user1
      post :create, { :auth_token => @user1.authentication_token, :friend_id => @user2 }
      contents = JSON.parse(response.body)
      
      expect(contents['error']).to match /That user is already your friend or has a pending request/
    end
    
    it "cannot add when both db transactions aren't successful" do
      Friendship.any_instance.stub(:save!).and_raise(ActiveRecord::RecordNotSaved)
      post :create, { :auth_token => @user1.authentication_token, :friend_id => @user2 }
      contents = JSON.parse(response.body)
      
      expect(contents['error']).to match /Friend records unable to save/
    end
  
  end
  
  describe 'user update friend' do
    
    before :each do
      @user1 = FactoryGirl.create(:user, :unique_email)
      @user2 = FactoryGirl.create(:user, :unique_email)
    end
    
    it 'should allow updating of friendships' do
      @user1.requested_friends << @user2
      @user2.pending_friends << @user1
      put :update, { :auth_token => @user1.authentication_token, :friend_id => @user2 }
      
      success = response.success?
      expect(success).to be_true
    end
    
    it "should update the friendship status to 'confirmed' for user" do
      @user1.requested_friends << @user2
      @user2.pending_friends << @user1
      action = expect { put :update, { :auth_token => @user1.authentication_token, :friend_id => @user2 } }
      action.to change(@user1.friends, :count).by(1)
    end
    
    it "should update the friendship status to 'confirmed' for friend" do
      @user1.requested_friends << @user2
      @user2.pending_friends << @user1
      action = expect { put :update, { :auth_token => @user1.authentication_token, :friend_id => @user2 } }
      action.to change(@user2.friends, :count).by(1)
    end
  
    it 'cannot change friend status if the users are not friends' do
      put :update, { :auth_token => @user1.authentication_token, :friend_id => @user2 }
      contents = JSON.parse(response.body)
      
      expect(contents['error']).to match /Cannot update a friendship that doesn't exist/
    end
    
    it "cannot update when both db transactions aren't successful" do
      @user1.requested_friends << @user2
      @user2.pending_friends << @user1
      
      Friendship.any_instance.stub(:update_attributes!).and_raise(ActiveRecord::RecordNotSaved)
      put :update, { :auth_token => @user1.authentication_token, :friend_id => @user2 }
      contents = JSON.parse(response.body)
      
      expect(contents['error']).to match /Friend records unable to update/
    end
  
  end
  
  describe 'user destroy friend' do
    
    before :each do
      @user1 = FactoryGirl.create(:user, :unique_email)
      @user2 = FactoryGirl.create(:user, :unique_email)
    end
    
    it "should allow deleting of friendships" do
      @user1.friends << @user2
      @user2.friends << @user1
      delete :destroy, { :auth_token => @user1.authentication_token, :friend_id => @user2 }
      
      success = response.success?
      expect(success).to be_true
    end
    
    it 'should remove the friendship for the user on delete' do
      @user1.requested_friends << @user2
      @user2.pending_friends << @user1
      action = expect { delete :destroy, { :auth_token => @user1.authentication_token, :friend_id => @user2 } }
      action.to change(@user1.friendships, :count).by(-1)
    end
    
    it 'should remove the friendship for the friend on delete' do
      @user1.requested_friends << @user2
      @user2.pending_friends << @user1
      action = expect { delete :destroy, { :auth_token => @user1.authentication_token, :friend_id => @user2 } }
      action.to change(@user2.friendships, :count).by(-1)
    end
  
    it 'cannot destroy friend if the users are not friends' do
      delete :destroy, { :auth_token => @user1.authentication_token, :friend_id => @user2 }
      contents = JSON.parse(response.body)
      
      expect(contents['error']).to match /Cannot delete a user and friend without friendship/
    end
    
    it "cannot destroy when both db transactions aren't successful" do
      user1 = FactoryGirl.create(:user, :unique_email)
      user2 = FactoryGirl.create(:user, :unique_email)
      user1.requested_friends << user2
      user2.pending_friends << user1
      
      Friendship.any_instance.stub(:destroy!).and_raise(ActiveRecord::RecordNotSaved)
      delete :destroy, { :auth_token => user1.authentication_token, :friend_id => user2 }
      contents = JSON.parse(response.body)
      
      expect(contents['error']).to match /Friend records unable to delete/
    end
  
  end

end
