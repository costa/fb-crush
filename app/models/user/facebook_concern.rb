module User::FacebookConcern
  extend ActiveSupport::Concern

  included do

    def self.create_with_facebook(fb_user)
      create! do |user|
        user.provider = 'facebook'
        user.uid = fb_user.identifier
        user.name = fb_user.name
        user.email = fb_user.email
      end
    end

  end

  def facebook_setup(access_token)
    @access_token = access_token  # XXX through an exception if changing?
    poll_facebook do
      update_facebook_friends
    end  unless @access_token.blank?
  end

  def facebook_me
    return @facebook_me  unless @access_token.present?
    @facebook_me ||= FbGraph::User.me(@access_token)
  end


  private

  def poll_facebook
    if !facebook_fetched_at || facebook_fetched_at < FACEBOOK_POLLING_INTERVAL_MINUTES.minutes.ago
      yield
      touch :facebook_fetched_at
    end
  end

  def update_facebook_friends
    fb_actual = facebook_me.friends

    # create
    fb_actual.each do |fb_friend|
      friends.create! do |friend|
        friend.user = User.create_with_facebook(fb_friend)
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
