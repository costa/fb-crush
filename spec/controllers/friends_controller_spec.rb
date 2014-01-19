require 'spec_helper'

describe FriendsController do
  render_views

  before do
    @friend = FactoryGirl.create(:friend)
    @user = @friend.ego
    @friend_user = @friend.user
  end

  describe "GET index, for non-logged in user" do
    it "redirects user to the home path to login" do
      session[:user_id] = nil
      get 'index'
      response.should redirect_to(root_path)
    end
  end

  describe "for logged in users" do
    before do
      session[:user_id] = @user.id
    end

    describe "PUT update" do
      before do
        put 'update', id: id, friend: friend_params
      end

      let(:id) { @friend.id }
      let(:friend_params) { { intention: 'love' } }

      describe "with invalid params" do
        let(:id) { 0 }

        it "redirects to index and alerts user on error" do
          response.should redirect_to(friends_path)
          flash[:alert].should_not be_blank
        end
      end

      it "redirects to index and notices user on success" do
        response.should redirect_to(friends_path)
        assigns[:friend].should_not be_blank
        assigns[:friend].should be_valid
        flash[:notice].should_not be_blank
      end
    end
  end

end
