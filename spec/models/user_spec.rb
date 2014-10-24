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

    it "should destroy no-longer friends"

  end

end
