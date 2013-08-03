FactoryGirl.define do

  factory :user do
    email Faker::Internet.email
    password "testingpass"
  end

end
