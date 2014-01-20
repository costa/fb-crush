class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user
  helper_method :user_signed_in?

  before_filter :current_user_facebook_setup

  private

  def current_user
    return @current_user  if defined? @current_user
    @current_user = UserDecorator.find(session[:user_id]) rescue nil
  end

  def user_signed_in?
    !!current_user
  end

  def authenticate_user!
    redirect_to root_path, :alert => t('application.authenticate_user.alert')  unless user_signed_in?
  end

  def current_user_facebook_setup
    current_user.facebook_setup(session[:facebook_access_token])  if user_signed_in?
  end

end
