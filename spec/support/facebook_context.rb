shared_context "not fetching facebook friends", :type => :controller do

  before do
    User.any_instance.stub :fetch_friends_async
    User.any_instance.stub(:should_sign_in?).and_return false
  end

  # NOTE stubs are supposedly cleared after each test

end
