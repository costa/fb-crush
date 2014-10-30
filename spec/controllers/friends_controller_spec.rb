require 'rails_helper'

describe FriendsController do
  render_views

  before do
    @friend = FactoryGirl.create(:friend)
    @user = @friend.ego
    @friend_user = @friend.user
    @another_friend = FactoryGirl.create(:friend, ego: @user)
    @another_friend.symmetrical_friend.update_attributes!(intention: 'love')
  end

  describe "GET index, for non-logged in user" do

    it "redirects user to the game path to login" do
      session[:user_id] = nil
      get 'index'
      response.should redirect_to(game_path)
    end

  end

  describe "for logged in users" do

    before do
      session[:user_id] = @user.id
    end

    it "renders a list of friends including mutual intention" do
      @another_friend.update_attributes!(intention: 'love')
      get 'index'
      response.should be_success
      assigns[:friends].to_set.should eq(@user.friends.to_set)
    end

    describe "PUT update" do

      before do
        xhr :put, 'update', id: id, friend: friend_params
      end

      let(:id) { @friend.id }
      let(:friend_params) { { intention: 'love' } }

      describe "with invalid params" do

        let(:id) { 0 }

        it "alerts the user on error" do
          flash[:alert].should_not be_blank  # XXX TMP
        end

      end

      it "notifies the user on success" do
        flash[:notice].should_not be_blank  # XXX tmp
      end

      it "really updates the record" do
        Friend.find(id).intention.should eq 'love'
      end

      describe "when mutual" do

        let(:id) { @another_friend.id }

        it "notifies the user on success" do
          flash[:notice].should_not be_blank  # XXX TMP
        end

      end

      describe "when blank" do

        let(:friend_params) {
          @friend.update_attributes!(intention: 'love')  # XXX an ugly befores order hack
          { intention: '' }
        }

        it "notifies the user on success" do
          flash[:notice].should_not be_blank  # XXX TMP
        end

        it "really updates the record" do
          Friend.find(id).intention.should eq nil
        end

      end

    end

  end

end
