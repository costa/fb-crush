module Concerns::Facebook
    extend ActiveSupport::Concern

    included do

      before_filter :current_user_friends_fetch

    end


    private

    def current_user_friends_fetch
      flash.now.alert = t('flash.concerns.facebook.alert')  if
        user_signed_in? && current_user.fetch_friends
    end

end
