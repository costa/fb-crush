class FriendsController < ApplicationController

  respond_to :json, :except => :app

  before_filter :authenticate_user!

  def app
  end

  def update
    respond_with scope.update params[:id], friend_params
  end


  private

  def scope
    current_user.friends
  end

  def friend_params
    # params.require(:friend).permit(:intention)
    params.permit(:intention)  # XXX mystery! the above should work due to a mysterious addition of "friend"=>{"intention"=>...} to the params. Alas!
  end

end
