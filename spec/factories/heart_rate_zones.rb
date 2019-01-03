FactoryBot.define do
  factory :heart_rate_zones do
    association :athlete, factory: :athlete

    custom_zones { false }

    zone_1_min { 0 }
    zone_1_max { 140 }
    zone_2_min { 140 }
    zone_2_max { 150 }
    zone_3_min { 150 }
    zone_3_max { 160 }
    zone_4_min { 160 }
    zone_4_max { 170 }
    zone_5_min { 170 }
    zone_5_max { -1 }
  end
end
