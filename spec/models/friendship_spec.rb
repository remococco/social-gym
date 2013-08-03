require 'spec_helper'

describe Friendship do
  
  describe 'friendship status' do
    
    [:pending, :requested, :confirmed].each do |status|
      it "should allow '#{status}'" do
        friendship = Friendship.new(:status => status.to_s)
        expect(friendship.valid?).to be_true
      end
    end
    
    it 'should not allow an invalid status' do
      friendship = Friendship.new(:status => 'invalid')
      expect(friendship.valid?).to be_false
    end
    
  end

end
