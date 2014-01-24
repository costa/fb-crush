class FriendsController < ApplicationController

  before_filter :authenticate_user!
  decorates_assigned :friend, :friends

  def index
    @friends = scope.for_index
  end

  def update
    @friend = scope.find_by_id(params[:id])
    error =
      if @friend
        @friend.errors.full_messages.join('; ')  unless @friend.update_attributes(friend_params)
      else
        I18n.t('actioncontroller.errors.controllers.friends.actions.update.not_found')
      end
    if error
      flash[:alert] = t('flash.friends.update.alert', error: error)
    else
      flash[:notice] = t(friend.mutual_intention?? 'flash.friends.update.notice_mutual': 'flash.friends.update.notice',
                         name: friend.name, intention: friend.intention_t)
    end
    redirect_to friends_path
  end


  private

  def scope
    current_user.friends
  end

  def friend_params
    params.require(:friend).permit(:intention)
  end

end
