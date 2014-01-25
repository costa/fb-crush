class AddMutualIntentionSinceToFriends < ActiveRecord::Migration

  def up
    add_column :friends, :mutual_intention_since, :datetime
    add_column :friends, :different_intention_since, :datetime

    Friend.find_each &:save!
  end

  def down
    remove_column :friends, :mutual_intention_since
    remove_column :friends, :different_intention_since
  end

end
