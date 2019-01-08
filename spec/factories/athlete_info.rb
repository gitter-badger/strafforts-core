FactoryBot.define do
  factory :athlete_info do
    association :athlete, factory: :athlete
  end
end
