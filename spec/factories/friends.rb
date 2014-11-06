FactoryGirl.define do

  factory :friend do
    association :ego, :factory => :user
    association :user
  end

end
