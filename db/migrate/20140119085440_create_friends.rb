class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends do |t|
      t.references :ego
      t.references :user
      t.string :intention

      t.timestamps

      t.index :ego_id
      t.index [:ego_id, :user_id], :unique => true
    end
  end
end
