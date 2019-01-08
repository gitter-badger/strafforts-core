FactoryBot.define do
  factory :athlete do
    access_token { Faker::Crypto.unique.md5 }
    is_active { false }
    is_public { false }
    updated_at { Time.new(2018, 12, 1, 15, 0) }
    email { "tony.stark@avenger.com" }

    after :build do |athlete|
      FactoryBot.create(:athlete_info, athlete: athlete)
    end

    trait :created_a_week_ago do
      created_at { 1.week.ago }
    end

    trait :create_today do
      created_at { 1.hour.ago }
    end

    trait :email_confirmed do
      email_confirmed { true }
      confirmation_token { nil }
      confirmation_sent_at { nil }
    end

    trait :email_unconfirmed do
      email_confirmed { false }
      confirmation_token { SecureRandom.urlsafe_base64(32).to_s }
      confirmation_sent_at { 1.hour.ago }
    end

    trait :public do
      is_public { true }
    end

    trait :with_heart_rate_zones do
      after :build do |athlete|
        FactoryBot.create(:heart_rate_zones, athlete: athlete)
      end
    end

    factory :athlete_with_public_profile, traits: %i[public]
    factory :athlete_created_a_week_ago_with_email_unconfirmed, traits: %i[created_a_week_ago email_unconfirmed]
    factory :athlete_created_today_with_email_confirmed, traits: %i[create_today email_confirmed]
    factory :athlete_created_today_with_email_unconfirmed, traits: %i[create_today email_unconfirmed]
    factory :athlete_with_heart_rate_zones, traits: %i[with_heart_rate_zones]
  end
end
