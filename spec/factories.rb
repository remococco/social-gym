FactoryGirl.define do

  factory :user do
    email Faker::Internet.email
    password "testingpass"
    
    trait :unique_email do
      sequence(:email) { |n| "person#{n}@test.com" }
    end
    
    after(:create) do |user|
      user.ensure_authentication_token!
    end
  end

end
