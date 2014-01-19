require 'spec_helper'

describe Friend do
  it "should be manufactured valid" do
    FactoryGirl.build(:friend).should be_valid
  end

  it "should create a single symmetrical object" do
    friend = FactoryGirl.create(:friend)
    Friend.where(ego: friend.user, user: friend.ego).count.should eq(1)
  end

  it "should destroy itself and its symmetrical object" do
    friend = FactoryGirl.create(:friend)
    friend.destroy.should be_true
    Friend.where(ego: friend.user, user: friend.ego).should be_empty
  end
end
