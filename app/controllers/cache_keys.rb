module CacheKeys
  ALL_BEST_EFFORT_TYPES = "global/best_effort_types".freeze
  ALL_RACE_DISTANCES = "global/race_distances".freeze
  ALL_FAQS = "global/faqs".freeze
  ALL_FAQ_CATEGORIES = "global/faq_categories".freeze
  ALL_SUBSCRIPTION_PLANS = "global/subscription_plans".freeze
  ALL_WORKOUT_TYPES = "global/workout_types".freeze

  BEST_EFFORT_TYPES = "global/best_effort_types/%{distance}".freeze
  RACE_DISTANCES = "global/race_distances/%{distance}".freeze
end
