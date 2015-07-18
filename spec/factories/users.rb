FactoryGirl.define do
  factory :user do
    sequence(:email) { |i| "user#{i}@example.com" }
    sequence(:password) { |i| "password#{i}" }
  end

end
