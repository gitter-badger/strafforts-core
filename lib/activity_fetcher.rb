class ActivityFetcher
  def initialize(access_token)
    raise ArgumentError, "ActivityFetcher - Blank access token was passed in." if access_token.blank?

    @access_token = access_token
    @api_wrapper = StravaApiWrapper.new(@access_token)
  end

  def fetch_all(options = {}) # rubocop:disable AbcSize, CyclomaticComplexity, MethodLength, PerceivedComplexity
    mode = options[:mode] || "latest"
    type = options[:type] || %w[best-efforts personal-bests races]

    begin
      # Call Strava API: to get a detailed view of the current athlete.
      # Create or update the current athlete first.
      current_athlete = @api_wrapper.retrieve_current_athlete
      athlete = Creators::AthleteCreator.create_or_update(@access_token, current_athlete, true)

      # Create or update athlete's gears.
      Creators::GearCreator.create(@access_token, athlete.id, current_athlete["shoes"])

      # Call Strava API: to get the HR zones of the current athlete.
      current_athlete_zones = @api_wrapper.retrieve_current_athlete_zones
      Creators::HeartRateZonesCreator.create_or_update(athlete.id, current_athlete_zones)

      Rails.logger.info("ActivityFetcher - Start fetching activities for athlete #{athlete.id}.")

      # Retrieve activities of the current athlete.
      activities_to_retrieve = []
      current_total_run_count = retrieve_current_total_run_count(athlete.id)
      if mode == "all" || athlete.total_run_count != current_total_run_count
        activity_ids = get_all_activity_ids(type)
        activity_ids.sort.each do |activity_id|
          older_than_last_retrieved = athlete.last_activity_retrieved.blank? || activity_id > athlete.last_activity_retrieved # rubocop:disable LineLength
          activities_to_retrieve << activity_id if mode == "all" || older_than_last_retrieved
        end

        if activities_to_retrieve.count.positive?
          Rails.logger.info("ActivityFetcher - A total of #{activities_to_retrieve.count} "\
            "activities to be retrieved for athlete #{athlete.id}.")

          activities_to_retrieve.sort.each do |activity_id|
            begin
              # Call Strava API: to get a detailed view of the activity.
              activity = @api_wrapper.retrieve_an_activity(activity_id)
              Creators::ActivityCreator.create_or_update(activity)
            rescue StandardError => e
              Rails.logger.error("ActivityCreator - Error creating or updating activity '#{activity_id}'. "\
                "#{e.message}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
              raise if e.message.include?("Authorization Error") # rubocop:disable BlockNesting

              next
            end
            athlete.last_activity_retrieved = activity_id
            athlete.save!
          end
        else
          Rails.logger.info(get_no_new_runs_message(athlete.id, current_total_run_count))
        end

        athlete.total_run_count = current_total_run_count
        athlete.save!
      else
        Rails.logger.info(get_no_new_runs_message(athlete.id, current_total_run_count))
      end
    rescue StandardError => e
      Rails.logger.error("ActivityFetcher - Error fetching athlete (access_token=#{@access_token}). "\
        "#{e.message}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
      if e.message.include?("Authorization Error")
        athlete = Athlete.find_by(access_token: @access_token)
        unless athlete.nil?
          athlete.is_active = false
          athlete.save!
        end
      end
    end
  end

  private

  # Get ids of all running activities that have achievement items or are races.
  def get_all_activity_ids(type) # rubocop:disable CyclomaticComplexity
    # Call Strava API: to list all athlete activities, then parse out all activity ids.
    athlete_activities = @api_wrapper.list_all_athlete_activities

    # For all activity ids, choose running activities only,
    # then select those without achievement items or have workout_type of race.
    activity_ids = []
    athlete_activities.each do |page|
      page.each do |activity|
        activity_json = JSON.parse(activity.to_json)

        # Only care about running activities.
        next unless activity_json["type"] == "Run"

        # Best efforts (need to analyse all activities).
        activity_ids << activity_json["id"] if type.include?("best-efforts")

        # Personal Bests.
        has_pbs = type.include?("personal-bests") && activity_json["achievement_count"].positive?
        activity_ids << activity_json["id"] if has_pbs

        # Races.
        activity_ids << activity_json["id"] if type.include?("races") && (activity_json["workout_type"] == 1)
      end
    end
    activity_ids.uniq!
    activity_ids
  end

  def get_no_new_runs_message(athlete_id, total_run_count)
    "ActivityFetcher - No new runs found for athlete #{athlete_id}. Total run count: #{total_run_count}."
  end

  def retrieve_current_total_run_count(athlete_id)
    # Call Strava API: to get athlete's total run count.
    totals_and_stats = @api_wrapper.totals_and_stats(athlete_id)
    totals_and_stats_json = JSON.parse(totals_and_stats.to_json)
    totals_and_stats_json["all_run_totals"]["count"]
  end
end
