class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user
  helper_method :user_signed_in?

  private

    def current_user
      @current_user = UserDecorator.find(session[:user_id]) rescue nil  unless defined? @current_user
      @current_user
    end

    def user_signed_in?
      return true if current_user
    end

    def authenticate_user!
      redirect_to root_url, :alert => t('application.authenticate_user.alert') unless current_user
    end

end
