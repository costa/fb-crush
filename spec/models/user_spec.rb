require 'rails_helper'

describe User do

  it "should not be valid when blank" do
    subject.should_not be_valid
  end

  it "should be manufactured valid" do
    FactoryGirl.build(:friend).should be_valid
  end

  describe '#friends_fetch' do

    it "should create new friends"

    it "should update old friends"

    it "should not blank out missing data"

    it "should destroy no-longer friends"

    it "should blank out access token on appropriate exception"

  end

end
