require 'rails_helper'

describe Friend do

  subject { FactoryGirl.build(:friend) }

  it "should be manufactured valid" do
    expect(subject).to be_valid
  end

  describe "existing" do

    before do
      subject.save!
    end

    it "should create a single symmetrical object" do
      expect(Friend.where(ego: subject.user, user: subject.ego).count).to eq 1
    end

    it "should destroy itself and its symmetrical object" do
      subject.destroy.should be_truthy
      expect(Friend.where(ego: subject.user, user: subject.ego)).to be_empty
    end

    it "should set mutual intention" do
      symmetrical = subject.symmetrical_friend
      symmetrical.update_attributes! intention: 'love'
      subject.update_attributes! intention: 'love'

      subject.reload.should be_mutual_intention
      symmetrical.reload.should be_mutual_intention
    end

  end

end
