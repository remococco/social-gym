FactoryGirl.define do

  factory :user do
    email Faker::Internet.email
    password "testingpass"
    
    after(:create) do |user|
      user.ensure_authentication_token!
    end
  end

end
