class RenameFetchedAtInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :friends_fetched_at, :friends_fetched_at
  end
end
