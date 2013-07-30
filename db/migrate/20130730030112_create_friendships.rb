class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.integer :user_id
      t.integer :friend_id
      t.string :status, :null => false, :default => 'pending'

      t.timestamps
    end
  end
end
