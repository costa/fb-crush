class AddLastLoginAtAndLastSessionKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_login_at, :datetime
    add_column :users, :last_session_key, :string
  end
end
