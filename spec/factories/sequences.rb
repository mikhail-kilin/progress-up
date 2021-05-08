FactoryBot.define do
  sequence(:email) { |n| "user#{n}@example.com" }
  sequence(:password) { "12345689" }
end
