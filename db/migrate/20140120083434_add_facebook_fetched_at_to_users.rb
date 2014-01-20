class AddFacebookFetchedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :facebook_fetched_at, :datetime
  end
end
