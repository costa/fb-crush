class User < ActiveRecord::Base
  has_many :friends, :foreign_key => 'ego_id', :inverse_of => :ego

  validates_presence_of :name
  validates_uniqueness_of :uid, :scope => :provider


  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth[:provider]
      user.uid = auth[:uid]
      if info = auth[:info]
         user.name = info[:name]
         user.email = info[:email]
      end
    end
  end

end
