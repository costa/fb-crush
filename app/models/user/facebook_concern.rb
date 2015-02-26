module User::FacebookConcern
  extend ActiveSupport::Concern

  included do

    def self.find_or_create_with_facebook(fb_user)
      user = User.find_by_provider_and_uid('facebook', fb_user.identifier)
      user || create! {|user| user.validate_facebook_user_data fb_user}
    end

  end

  def fetch_friends_async(force=false)
    fetch_facebook_friends_async force  if should_fetch_facebook_friends?(force)
  end

  def facebook_me
    @facebook_me ||= FbGraph::User.me(access_token)  if facebook_accessible?
  end


  def validate_facebook_user_data(fb_user)
    self.provider = 'facebook'
    self.uid = fb_user.identifier.presence || uid
    self.name = fb_user.name.presence || name
    self.email = fb_user.email.presence || email
    valid?  # XXX before_validation callbacks and all around nice return value
  end

  def should_sign_in?
    !facebook_accessible?
  end

  private

  def facebook_accessible?
    provider == 'facebook' && access_token.present?
  end

  def should_fetch_facebook_friends?(force=false)
    facebook_accessible? && (force ||
      !friends_fetched_at || friends_fetched_at < facebook_polling_interval.ago
    )
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
        friend.save! if force
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
    Friend.disable_notifications force do
      begin
        fetch_facebook_friends force  if should_fetch_facebook_friends?(force)
      rescue FbGraph::InvalidToken => e
        logger.info "#{e.backtrace}\n- #{e.message} (#{e.class})"
        update! access_token: nil
      end
    end
  end
  handle_asynchronously :fetch_facebook_friends_async, :priority => EXTERNAL_BATCH_PRIORITY

end
