class AddCrushFriendIdsToFriends < ActiveRecord::Migration
  def change
    add_column :friends, :prev_crush_friend_id, :integer
    add_column :friends, :next_crush_friend_id, :integer
    add_index :friends, :prev_crush_friend_id
    add_index :friends, :next_crush_friend_id
  end
end
