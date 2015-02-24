class FriendsController < ApplicationController

  respond_to :json, :except => :app

  before_filter :authenticate_user!

  def app
  end

  def index
    respond_with scope.for_index
  end

  def update
    respond_with scope.update params[:id], friend_params
  end


  private

  def scope
    current_user.friends
  end

  def friend_params
    params.except(:id).permit(:intention)
  end

end
