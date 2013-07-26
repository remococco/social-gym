require 'spec_helper'

describe Api::SessionsController do

  before :each do
    devise_api_mappings
  end

  describe 'api sign in' do
    
    before :each do
      @user_attrs = FactoryGirl.attributes_for(:user)
      @user = User.create(@user_attrs)
      @email = @user_attrs[:email]
      @response = post(:create, @user_attrs)
      @contents = JSON.parse(@response.body)
    end
    
    it 'should sign in a valid user' do
      success = @response.success?
      
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
    
    describe 'should not sign in' do
    
      it 'with invalid email' do
        @user_attrs[:email] = "bademail@email.com"
        @response = post(:create, @user_attrs)
        @contents = JSON.parse(@response.body)
        
        success = @response.success?
        expect(success).to be_false
      end
    
      it 'with invalid password' do
        @user_attrs[:password] = "wrongpassword"
        @response = post(:create, @user_attrs)
        @contents = JSON.parse(@response.body)
        
        success = @response.success?
        expect(success).to be_false
      end
    
    end

  end
  
  describe 'api sign out' do
    
    before :each do
    end
    
    it 'should not be accessible by a non signed in session' do
      user_attrs = FactoryGirl.attributes_for(:user)
      user = User.create user_attrs
      user.ensure_authentication_token!

      response = delete(:destroy)#, :auth_token => user.authentication_token)
      contents = JSON.parse(response.body)
      
      $stderr.puts contents
    end
    
  end

end
