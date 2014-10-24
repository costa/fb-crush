module Concerns::Facebook
    extend ActiveSupport::Concern

    included do

      before_filter :current_user_friends_fetch

    end


    private

    def current_user_friends_fetch
      current_user.fetch_friends  if user_signed_in?
    end

end
