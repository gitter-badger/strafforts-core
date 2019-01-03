module CacheKeys
  ALL_BEST_EFFORT_TYPES = "global/best_effort_types".freeze
  ALL_RACE_DISTANCES = "global/race_distances".freeze
  ALL_FAQS = "global/faqs".freeze
  ALL_FAQ_CATEGORIES = "global/faq_categories".freeze
  ALL_SUBSCRIPTION_PLANS = "global/subscription_plans".freeze
  ALL_WORKOUT_TYPES = "global/workout_types".freeze

  BEST_EFFORT_TYPES = "global/best_effort_types/%{distance}".freeze
  RACE_DISTANCES = "global/race_distances/%{distance}".freeze

  META = "athletes/%{athlete_id}/meta".freeze

  HEART_RATE_ZONES = "athletes/%{athlete_id}/heart-rate-zones".freeze

  PBS_OVERVIEW = "athletes/%{athlete_id}/personal-bests/overview".freeze
  PBS_RECENT = "athletes/%{athlete_id}/personal-bests/recent".freeze
  PBS_DISTANCE = "athletes/%{athlete_id}/personal-bests/%{best_effort_type_id}".freeze

  RACES_OVERVIEW = "athletes/%{athlete_id}/races/overview".freeze
  RACES_RECENT = "athletes/%{athlete_id}/races/recent".freeze
  RACES_YEAR = "athletes/%{athlete_id}/races/%{year}".freeze
  RACES_DISTANCE = "athletes/%{athlete_id}/races/%{race_distance_id}".freeze
end
