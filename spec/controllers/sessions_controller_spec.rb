require 'spec_helper'

describe SessionsController do
  render_views

  describe "GET new" do
    it "redirectes users to authentication" do
      get 'new'
      assert_redirected_to '/auth/facebook'
    end
  end

  describe "with valid omniauth" do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:facebook] = HashWithIndifferentAccess.new(
        'uid' => '12345',
        'provider' => 'facebook',
        'credentials' => {
          'token' => 'ABC...'
        },
        'info' => {
          'name' => 'Bob'
        }
      )
    end

    describe "creates new user" do
      it "redirects users with email back to root_path" do
        @user = FactoryGirl.create(:user, :email => 'Tester@testing.com')
        mock_graph :get, 'me/friends', 'users/friends/me_private', :access_token => 'ABC...' do
          visit '/signin'
          page.should have_content("Signed in!")
          current_path.should == '/'
        end
      end
    end

  end

end
