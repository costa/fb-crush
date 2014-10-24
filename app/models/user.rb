class User < ActiveRecord::Base
  include FacebookConcern

  has_many :friends, ->{includes :user}, :foreign_key => 'ego_id', :inverse_of => :ego, :dependent => :destroy

  validates_presence_of :name
  validates_uniqueness_of :uid, :scope => :provider


  def self.find_by_provider_and_uid(provider, uid)
    where(provider: provider, uid: uid).first
  end

  def self.find_or_create_with_omniauth(auth)
    find_by_provider_and_uid(auth[:provider], auth[:uid].to_s) ||
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
