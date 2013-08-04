class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable
         
  has_many :friendships
  has_many :friends, -> { where "status = 'confirmed'" }, :through => :friendships
  has_many :requested_friends, -> { where "status = 'requested'" }, :through => :friendships, :source => :friend
  has_many :pending_friends, -> { where "status = 'pending'" }, :through => :friendships, :source => :friend
end
