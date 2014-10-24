class SessionsController < ApplicationController

  def new
    redirect_to '/auth/facebook'
  end

  def create
    auth = request.env['omniauth.auth']
    user = User.update_or_create_with_omniauth!(auth)

    # Reset the session after successful login, per
    # 2.8 Session Fixation – Countermeasures:
    # http://guides.rubyonrails.org/security.html#session-fixation-countermeasures
    reset_session
    session[:user_id] = user.id

    redirect_to friends_path, :notice => t('flash.sessions.create.notice')
  end

  def destroy
    reset_session
    redirect_to root_path, :notice => t('flash.sessions.destroy.notice')
  end

  def failure
    redirect_to root_path, :alert => t('flash.sessions.failure.alert', error: params[:message].humanize)
  end

end
