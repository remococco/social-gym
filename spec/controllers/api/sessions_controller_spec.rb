require 'spec_helper'

describe Api::SessionsController do

  before :each do
    devise_api_mappings
  end

  describe 'api sign in' do
    
    describe 'should sign in' do
    
      before :each do
        user_attrs = FactoryGirl.attributes_for(:user)
        User.create user_attrs
        @email = user_attrs[:email]
        post :create, user_attrs
        @contents = JSON.parse(response.body)
      end
    
      it 'should sign in a valid user' do
        success = response.success?
        expect(success).to be_true
      end
    
      it 'should have the correct email' do
        email = @contents['email']
        expect(email).to eq(@email)
      end
  
      it 'should give a valid token' do
        token = @contents['auth_token']
        expect(token).not_to be_nil
      end
    
    end
    
    describe 'should not sign in' do
      
      before :each do
        @user_attrs = FactoryGirl.attributes_for(:user)
        User.create @user_attrs
      end
      
      it 'with no email param' do
        @user_attrs[:email] = nil
        post :create, @user_attrs
        
        success = response.success?
        expect(success).to be_false
      end
    
      it 'with invalid email' do
        @user_attrs[:email] = "bademail@email.com"
        post :create, @user_attrs
        
        success = response.success?
        expect(success).to be_false
      end
    
      it 'with invalid password' do
        @user_attrs[:password] = "wrongpassword"
        post :create, @user_attrs
        
        success = response.success?
        expect(success).to be_false
      end
    
    end

  end
  
  describe 'api sign out' do

    it 'should not be accessible without a token' do
      delete :destroy
      
      success = response.success?
      expect(success).to be_false
    end
    
    it 'should not be accessible with an incorrect token' do
      user = FactoryGirl.create(:user)
      delete :destroy, :auth_token => "#{user.authentication_token}#{user.authentication_token}"
      
      success = response.success?
      expect(success).to be_false
    end
    
    describe 'success' do
      
      before :each do
        @user = FactoryGirl.create(:user)
        @auth_token = @user.authentication_token
        delete :destroy, :auth_token => @user.authentication_token
      end
      
      it 'should sign out' do
        success = response.success?
        expect(success).to be_true
      end
      
      it 'should reset auth token on valid sign out' do
        token_after_sign_out = User.find(@user).authentication_token
        expect(@auth_token).not_to eq(token_after_sign_out)
      end
    
    end
    
  end

end
