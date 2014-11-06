FactoryGirl.define do

  factory :user do
    provider 'facebook'
    uid { Forgery(:basic).password }
    name { Forgery(:name).full_name }
    friends_fetched_at { Forgery(:date).date(past: true) }

    # returning
    last_login_at { Forgery(:date).date(past: true) }
    sequence(:last_session_key) {|n| "session-#{n}"}

    trait :new do
      last_login_at nil
      last_session_key nil
    end
  end

end
