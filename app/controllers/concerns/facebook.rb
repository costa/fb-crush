module Concerns::Facebook
    extend ActiveSupport::Concern

    included do

      before_filter :if => :user_signed_in? do
        current_user.fetch_friends_async
      end

    end

end
