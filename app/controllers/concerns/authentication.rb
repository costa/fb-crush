module Concerns::Authentication
  extend ActiveSupport::Concern

  included do

    helper_method :current_user
    helper_method :user_signed_in?

  end


  private

  def current_user
    @current_user ||= User.find(session[:user_id]) rescue nil
  end

  def user_signed_in?
    !!current_user
  end

  def authenticate_user!  # XXX tmp
    redirect_to root_path, :alert => t('flash.application.authenticate_user.alert')  unless user_signed_in?
  end

end
