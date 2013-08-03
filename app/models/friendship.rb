class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => 'User'
  
  validates_inclusion_of :status, :in => ['pending', 'requested', 'confirmed']
end
