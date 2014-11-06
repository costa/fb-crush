FactoryGirl.define do

  factory :user do
    provider 'facebook'
    uid { Forgery(:basic).password }
    name { Forgery(:name).full_name }
    friends_fetched_at { Forgery(:date).date(past: true) }

    trait :returning do
      last_login_at { Forgery(:date).date(past: true) }
      sequence(:last_session_key) {|n| "session-#{n}"}
    end
  end

end
