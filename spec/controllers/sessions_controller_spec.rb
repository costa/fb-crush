describe SessionsController, :omniauth do

  let(:user) { build :user }

  before do
    request.env['omniauth.auth'] = auth_mock(user)
  end

  describe "#create" do

    it "creates a user" do
      expect {
        expect {
          post :create, provider: :facebook
        }.to change{ User.count }.by(1)
      }.to change{ subject.send :current_user }.from(nil)
    end

    it "creates a session" do
      expect {
        expect {
          expect {
            post :create, provider: :facebook
          }.to change{ session[:user_id] }.from(nil)
        }.to change{ subject.send(:current_user).try :last_login_at }.from(nil)
      }.to change{ subject.send(:current_user).try :last_session_key }.from(nil)
    end

    it "redirects to the home page" do
      post :create, provider: :facebook
      expect(response).to redirect_to root_url
    end

    describe "existing user" do

      let(:user) { create :user, :returning }

      it "creates and resets the session" do
        expect {
          expect {
            expect {
              post :create, provider: :facebook
            }.to change{ session[:user_id] }
          }.to change{ user.reload.last_login_at }
        }.to change{ user.reload.last_session_key }
      end

    end

  end

  describe "#destroy" do

    before do
      post :create, provider: :facebook
    end

    it "resets the session" do
      expect(session[:user_id]).not_to be_nil
      delete :destroy
      expect(session[:user_id]).to be_nil
    end

    it "redirects to the home page" do
      delete :destroy
      expect(response).to redirect_to root_url
    end

  end

end
