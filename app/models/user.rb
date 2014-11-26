class User < ActiveRecord::Base
  include FacebookConcern

  AUTH_INFO_ATTRS = %i[name email]

  has_many :friends, ->{includes :user}, :foreign_key => 'ego_id', :inverse_of => :ego, :dependent => :destroy

  strip_attributes

  validates_presence_of :name
  validates_uniqueness_of :uid, :scope => :provider


  class << self

    def find_by_provider_and_uid(provider, uid)
      where(provider: provider, uid: uid).first
    end

    def find_by_channel(channel)
      where(last_session_key: channel).first
    end

    def update_or_create_with_omniauth!(auth)
      user = find_or_initialize_by(provider: auth[:provider], uid: auth[:uid].to_s)
      attrs = {
        access_token: auth[:credentials][:token],
        last_login_at: Time.now,
        last_session_key: SecureRandom.hex
      }
      attrs.merge! auth[:info].slice *AUTH_INFO_ATTRS  if auth[:info]
      user.update_attributes! attrs
      user
    end

    def init_channel_async(channel)
      find_by_channel(channel).friends.init_channel channel
    end
    handle_asynchronously :init_channel_async, :priority => REALTIME_NOTIFICATIONS_PRIORITY

  end

  def pusher_channel
    last_session_key
  end

end
