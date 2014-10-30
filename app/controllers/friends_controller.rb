class FriendsController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!

  layout false, :only => :update

  def index
    @friends = scope.for_index
  end

  def update
    friend = scope.find_by_id(params[:id])
    error =
      if friend
        friend.errors.full_messages.join('; ')  unless friend.update friend_params
      else
        I18n.t('actioncontroller.errors.controllers.friends.actions.update.not_found')
      end
    if error
      flash.alert = t('flash.friends.update.alert', error: error)
    else
      flash.notice = t(
        if friend.mutual_intention?
          'flash.friends.update.notice_mutual'
        elsif friend.intention.blank?
          'flash.friends.update.notice_none'
        else
          'flash.friends.update.notice'
        end,
        name: friend.name,
        intention: friend.intention.presence && t(friend.intention, scope: 'enumerize.friend.intention')
      )

    end

    respond_with friend
  end


  private

  def scope
    current_user.friends
  end

  def friend_params
    params.require(:friend).permit(:intention)
  end

end
