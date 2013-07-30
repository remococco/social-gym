require 'spec_helper'

describe Api::FriendshipsController do

  describe "GET 'create'" do
    it "returns http success" do
      get 'create'
      response.should be_success
    end
  end

  describe "GET 'desotry'" do
    it "returns http success" do
      get 'desotry'
      response.should be_success
    end
  end

end
