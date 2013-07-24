require 'spec_helper'

describe Api::RegistrationsController do
  
  describe 'api sign up' do
  
    before :each do
      @email = 'testing@gmail.com'
      json = { :user => { :email => @email, :password => 'password', :password_confirmation => 'password' } }
      post :create, json
      @contents = JSON.parse(response.body)
    end
  
    it 'should sign up new users with a valid json request' do
      status = response.status
    
      expect(status).to eq(201)
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
  
  
  end

end
