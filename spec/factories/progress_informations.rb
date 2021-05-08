FactoryBot.define do
  factory :progress_information do
    content { Faker::Lorem.paragraph }
    amount { 1000 }
    association :article
  end
end
