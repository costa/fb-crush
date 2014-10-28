module User::FacebookConcern
  extend ActiveSupport::Concern

  included do

    def self.find_or_create_with_facebook(fb_user)
      user = User.find_by_provider_and_uid('facebook', fb_user.identifier)
      user || create! do |user|
        user.provider = 'facebook'
        user.uid = fb_user.identifier
        user.name = fb_user.name
        user.email = fb_user.email
      end
    end

  end

  def fetch_friends
    if provider == 'facebook' && access_token.present?
      poll_facebook do
        delay.update_facebook_friends
      end
    end
  end

  def facebook_me
    if provider == 'facebook' && access_token.present?
      @facebook_me ||= FbGraph::User.me(access_token)
    end
  end


  private

  def facebook_polling_interval
    ENV['FACEBOOK_POLLING_INTERVAL_MINUTES'].to_i.minutes
  end

  def poll_facebook
    if !friends_fetched_at || friends_fetched_at < facebook_polling_interval.ago
      yield
      touch :friends_fetched_at
    end
  end

  def update_facebook_friends
    fb_actual = facebook_me.friends

    # create
    fb_actual.each do |fb_friend|
      friends.create! do |friend|
        friend.user = User.find_or_create_with_facebook(fb_friend)
      end  unless friends.find_by_facebook_uid(fb_friend.identifier)
    end

    # destroy
    friends.reload.each do |friend|
      friend.destroy  unless
        fb_actual.any? do |fb_friend|
          fb_friend.identifier == friend.user.uid
        end
    end
  end

end
