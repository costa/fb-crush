module User::FacebookConcern
  extend ActiveSupport::Concern

  included do

    def self.find_or_create_with_facebook(fb_user)
      user = User.find_by_provider_and_uid('facebook', fb_user.identifier)
      user || create! {|user| user.validate_facebook_user_data fb_user}
    end

  end

  def fetch_friends_async(force=false)
    fetch_facebook_friends_async force  if facebook_accessible? && (force || should_fetch_facebook_friends?)
  end

  def facebook_me
    @facebook_me ||= FbGraph::User.me(access_token)  if facebook_accessible?
  end


  def validate_facebook_user_data(fb_user)
    self.provider = 'facebook'
    self.uid = fb_user.identifier
    self.name = fb_user.name
    self.email = fb_user.email
    valid?  # XXX before_validation callbacks and all around nice return value
  end

  private


  def facebook_accessible?
    provider == 'facebook' && access_token.present?
  end

  def should_fetch_facebook_friends?
    !friends_fetched_at || friends_fetched_at < facebook_polling_interval.ago
  end

  def facebook_polling_interval
    ENV['FACEBOOK_POLLING_INTERVAL_MINUTES'].to_i.minutes
  end

  def fetch_facebook_friends(force=false)
    fb_actual = facebook_me.friends

    fb_actual.each do |fb_friend|
      if friend = friends.find_by_facebook_uid(fb_friend.identifier)
        friend.user.validate_facebook_user_data fb_friend
        if friend.user.changed?
          friend.user.save!
        end
        if force
          def friend.notify?; false; end
          friend.save!
        end
      else
        friends.create! do |friend|
          friend.user = User.find_or_create_with_facebook(fb_friend)
        end
      end
    end

    # destroy
    friends.reload.each do |friend|
      friend.destroy  unless
        fb_actual.any? do |fb_friend|
          fb_friend.identifier == friend.user.uid
        end
    end

    touch :friends_fetched_at
  end

  def fetch_facebook_friends_async(force=false)
    fetch_facebook_friends force  if should_fetch_facebook_friends?
  end
  handle_asynchronously :fetch_facebook_friends_async, :priority => EXTERNAL_BATCH_PRIORITY

end
