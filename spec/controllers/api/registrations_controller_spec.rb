require 'spec_helper'

describe Api::RegistrationsController do
  
  before :each do
    warden_stubs
  end
  
  describe 'api sign up' do
  
    before :each do
      user_attrs = FactoryGirl.attributes_for(:user)
      @email = user_attrs[:email]
      response = post(:create, { :user => user_attrs })
      @contents = JSON.parse(response.body)
    end
  
    it 'should sign up new users with a valid json request' do
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
  
  describe 'invalid api sign up' do
  
    before :each do
      user_attrs = FactoryGirl.attributes_for(:user)
      user_attrs[:password] = nil
      @email = user_attrs[:email]
      response = post(:create, { :user => user_attrs })
      @contents = JSON.parse(response.body)
    end
    
    it 'should not sign up users with invalid json request' do
      success = response.success?
      
      expect(success).to be_false
    end
    
    it 'should return an error message' do
      error = @contents['error']
      
      expect(error).not_to be_nil
    end
  
  end

end
