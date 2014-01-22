module Concerns::Facebook
    extend ActiveSupport::Concern

    included do

      before_filter :current_user_facebook_setup

    end


    private

    def current_user_facebook_setup
      current_user.facebook_setup(session[:facebook_access_token])  if user_signed_in?
    end

end
