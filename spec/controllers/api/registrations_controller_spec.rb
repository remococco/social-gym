require 'spec_helper'

describe Api::RegistrationsController do
  
  describe 'api sign up' do
  
    before :each do
      @email = 'testing@gmail.com'
      json = { :user => { :email => @email, :password => 'password' } }
      response = post(:create, json)
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
      # TODO refactor this out
      allow_message_expectations_on_nil()
      request.env['warden'].stub(:custom_failure!)
      
      @email = 'testing@gmail.com'
      json = { :user => { :email => @email, :password => nil } }
      response = post(:create, json)
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
