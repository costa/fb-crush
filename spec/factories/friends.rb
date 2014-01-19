# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :friend do
    association :ego, :factory => :user
    association :user
  end
end
