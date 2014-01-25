require 'spec_helper'

describe Friend do

  let(:subject) { FactoryGirl.create(:friend) }

  it "should be manufactured valid" do
    subject.should be_valid
  end

  it "should create a single symmetrical object" do
    Friend.where(ego: subject.user, user: subject.ego).count.should eq(1)
  end

  it "should destroy itself and its symmetrical object" do
    subject.destroy.should be_true
    Friend.where(ego: subject.user, user: subject.ego).should be_empty
  end

  it "should set mutual intention" do
    symmetrical = subject.symmetrical_friend
    subject.intention = symmetrical.intention = 'love'
    subject.save.should be_true
    symmetrical.save.should be_true

    subject.should be_mutual_intention
    symmetrical.should be_mutual_intention
  end

end
