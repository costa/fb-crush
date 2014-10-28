class ApplicationController < ActionController::Base
  include Concerns::Authentication
  include Concerns::Facebook

  protect_from_forgery

  before_filter :reset_unauthenticated_session

  private

  def reset_unauthenticated_session
    reset_session  unless user_signed_in?
  end

end
