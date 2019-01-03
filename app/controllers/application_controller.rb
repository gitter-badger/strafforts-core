require "creators/activity_creator"
require "creators/athlete_creator"
require "creators/gear_creator"
require "creators/heart_rate_zones_creator"
require "creators/location_creator"
require "creators/refresh_token_creator"
require "creators/subscription_creator"
require "activity_fetcher"
require "mailer_lite_api_wrapper"
require "strava_api_wrapper"
require "stripe_api_wrapper"

class ApplicationController < ActionController::Base
  STRAVA_API_AUTH_AUTHORIZE_URL = Settings.strava.api_auth_authorize_url
  STRAVA_API_AUTH_TOKEN_URL = Settings.strava.api_auth_token_url
  STRAVA_API_CLIENT_ID = Settings.strava.api_client_id
  STRAVA_ATHLETES_BASE_URL = "#{Settings.strava.url}/athletes".freeze

  RECENT_ITEMS_LIMIT = 20
  BEST_EFFORTS_LIMIT = 100

  protect_from_forgery with: :exception

  def self.get_authorize_url(request)
    "#{STRAVA_API_AUTH_AUTHORIZE_URL}"\
    "?client_id=#{STRAVA_API_CLIENT_ID}"\
    "&response_type=code"\
    "&redirect_uri=#{request.protocol}#{request.host}:#{request.port}/auth/exchange-token"\
    "&approval_prompt=auto&scope=read,profile:read_all,activity:read"
  end

  def self.get_meta(athlete_id) # rubocop:disable AbcSize, MethodLength
    Rails.cache.fetch(format(CacheKeys::META, athlete_id: athlete_id)) do
      athlete = Athlete.find_by(id: athlete_id)
      return {} if athlete.nil?

      athlete = athlete.decorate
      athlete_info = {
        has_pro_subscription: athlete.pro_subscription?
      }

      best_efforts_meta = []
      ApplicationHelper::Helper.all_best_effort_types.each do |item|
        model = BestEffortType.find_by_name(item[:name])
        next if model.nil?

        # Limit to 1. Only need to check if there are any at this stage.
        best_efforts = BestEffort.find_top_by_athlete_id_and_best_effort_type_id(athlete_id, model.id, 1)
        result = {
          name: item[:name],
          count: best_efforts.nil? ? 0 : best_efforts.size,
          is_major: item[:is_major]
        }
        best_efforts_meta << result
      end

      personal_bests_meta = []
      ApplicationHelper::Helper.all_best_effort_types.each do |item|
        model = BestEffortType.find_by_name(item[:name])
        next if model.nil?

        personal_bests = BestEffort.find_all_pbs_by_athlete_id_and_best_effort_type_id(athlete_id, model.id)
        result = {
          name: item[:name],
          count: personal_bests.size,
          is_major: item[:is_major]
        }
        personal_bests_meta << result
      end

      races_by_distance_meta = []
      ApplicationHelper::Helper.all_race_distances.each do |item|
        model = RaceDistance.find_by_name(item[:name])
        next if model.nil?

        races = Race.find_all_by_athlete_id_and_race_distance_id(athlete_id, model.id)
        result = {
          name: item[:name],
          count: races.size,
          is_major: item[:is_major]
        }
        races_by_distance_meta << result
      end

      races_by_year_meta = []
      items = Race.find_years_and_counts_by_athlete_id(athlete_id)
      items.each do |item|
        result = {
          name: item[0].to_i.to_s,
          count: item[1],
          is_major: true
        }
        races_by_year_meta << result
      end

      {
        athlete_info: athlete_info,
        best_efforts: best_efforts_meta,
        personal_bests: personal_bests_meta,
        races_by_distance: races_by_distance_meta,
        races_by_year: races_by_year_meta
      }
    end
  end

  def self.set_last_active_at(athlete) # rubocop:disable AccessorMethodName
    athlete.last_active_at = Time.now.utc
    athlete.save!
  end

  def self.raise_athlete_not_found_error(id)
    error_message = "Could not find the requested athlete '#{id}' by id."
    raise ActionController::RoutingError, error_message
  end

  def self.raise_athlete_not_accessible_error(id)
    error_message = "Could not access athlete '#{id}'."
    raise ActionController::RoutingError, error_message
  end
end
