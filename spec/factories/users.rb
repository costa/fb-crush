# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    provider 'facebook'
    uid { Forgery(:basic).password }
    name { Forgery(:name).full_name }
  end
end
