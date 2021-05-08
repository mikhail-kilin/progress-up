FactoryBot.define do
  factory :user do
    full_name { Faker::Name.name }
    email { generate(:email) }
    password { "password" }
    phone { "79999999999" }
    description { "I am User" }
  end
end
