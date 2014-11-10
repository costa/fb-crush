require 'rails_helper'

describe FriendsController do
  render_views

  before do
    @friend = create :friend
    @user = @friend.ego
    @friend_user = @friend.user
    @another_friend = create :friend, ego: @user
    @another_friend.symmetrical_friend.update! intention: 'love'
  end

  describe "GET index, for non-logged in user" do

    it "redirects user to the root path to login" do
      session[:user_id] = nil
      get 'index'
      expect(response).to redirect_to root_path
    end

  end

  describe "for logged in users" do

    before do
      session[:user_id] = @user.id
    end

    describe "GET index" do

      it "renders a list of friends including mutual intention" do
        @another_friend.update! intention: 'love'
        get 'index'
        expect(response).to be_success
        assigns[:friends].to_set.should eq(@user.friends.to_set)  # XXX tmp
      end

    end

    describe "PATCH update" do

      let(:update_response) do
        xhr :patch, 'update', friend_params
        response
      end

      let(:id) { @friend.id }
      let(:friend_params) { { id: id, intention: 'love' } }

      describe "with invalid params" do

        let(:id) { 0 }

        it "responds with error" do
          expect{ update_response }.to raise_error
        end

      end

      it "responds with success" do
        expect(update_response).to be_success
      end

      it "really updates the record" do
        expect { update_response }.to change {
          Friend.find(id).intention
        }.from(nil).to('love')
      end

      describe "when blank" do

        let(:friend_params) { { id: id, intention: '' } }

        before do
          @friend.update! intention: 'love'
        end

        it "responds with success" do
          expect(response).to be_success
        end

        it "really updates the record" do
          expect { update_response }.to change {
            Friend.find(id).intention
          }.from('love').to(nil)
        end

      end

    end

  end

end
