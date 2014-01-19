require 'spec_helper'

describe User do
  it "should not be valid when blank" do
    subject.should_not be_valid
  end

  it "should be manufactured valid" do
    FactoryGirl.build(:friend).should be_valid
  end
end
