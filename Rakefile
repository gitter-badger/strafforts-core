# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"
require_relative "lib/activity_fetcher"
require_relative "lib/mailer_lite_api_wrapper"
require_relative "lib/strava_api_wrapper"
require_relative "lib/creators/activity_creator"
require_relative "lib/creators/athlete_creator"
require_relative "lib/creators/gear_creator"
require_relative "lib/creators/heart_rate_zones_creator"
require_relative "lib/creators/location_creator"
require_relative "lib/creators/refresh_token_creator"
require_relative "lib/creators/subscription_creator"

Rails.application.load_tasks
