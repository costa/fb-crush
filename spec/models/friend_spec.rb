require 'rails_helper'

describe Friend do

  subject { FactoryGirl.build(:friend) }
  let(:symmetrical) { subject.symmetrical_friend }


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
      expect {
        expect {
          symmetrical.update! intention: 'love'
          subject.update! intention: 'love'
        }.to change{ subject.reload.mutual_intention? }.from(false).to(true)
      }.to change{ symmetrical.reload.mutual_intention? }.from(false).to(true)
    end

  end

  describe "notifications", :type => :concern, :notifications => :test do

    it "should send on CRUD in real time" do
      stub1 = stub_pusher pusher_body('created', [subject.ego.pusher_channel], subject.as_json.merge(id: 235738))  # XXX (id: //))
      stub2 = stub_pusher pusher_body('created', [subject.user.pusher_channel], symmetrical.as_json.merge(id: 235738))  # XXX (id: //))
      subject.save!
      expect(stub1).to have_been_requested.once
      expect(stub2).to have_been_requested.once
      remove_request_stub stub1
      remove_request_stub stub2

      stub3 = stub_pusher pusher_body('updated', [subject.ego.pusher_channel], subject.as_json.merge(intention: 'love'))
      subject.update! intention: 'love'
      expect(stub3).to have_been_requested.once
      remove_request_stub stub3

      stub5 = stub_pusher pusher_body('updated', [subject.ego.pusher_channel], subject.as_json.merge(is_mutual_intention: true))
      stub6 = stub_pusher pusher_body('updated', [subject.user.pusher_channel], symmetrical.as_json.merge(intention: 'love', is_mutual_intention: true))
      symmetrical.update! intention: 'love'
      expect(stub5).to have_been_requested.once
      expect(stub6).to have_been_requested.once
      remove_request_stub stub5
      remove_request_stub stub6

      stub7 = stub_pusher pusher_body('destroyed', [subject.ego.pusher_channel], subject.as_json.merge(is_destroyed: true))
      stub8 = stub_pusher pusher_body('destroyed', [subject.user.pusher_channel], symmetrical.as_json.merge(is_destroyed: true))
      subject.destroy
      expect(stub7).to have_been_requested.once
      expect(stub8).to have_been_requested.once
      remove_request_stub stub7
      remove_request_stub stub8
    end

  end

end
