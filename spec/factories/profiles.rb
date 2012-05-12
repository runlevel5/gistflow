FactoryGirl.define do
  factory :profile do
    sequence(:email) { |n| "user_#{n}@gistflow.com" }
    company { Faker::Name.name }
    home_page { "http://#{Faker::Internet.domain_name}" }
  end
end