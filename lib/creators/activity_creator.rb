module Creators
  class ActivityCreator
    class << self
      def create_or_update(activity_hash)
        activity_json = JSON.parse(activity_hash.to_json)

        return if activity_json["best_efforts"].blank? && activity_json["workout_type"].to_i != 1

        create_activity(activity_json)

        # It's a race.
        if activity_json["workout_type"].to_i == 1
          Rails.logger.info("ActivityCreator - Activity #{activity_json['id']} is a race.")
          create_race(activity_json)
        end

        # It has some best efforts.
        activity_json["best_efforts"].each do |best_effort_json|
          create_best_effort(activity_json, best_effort_json)
        end
      end

      private

      def get_best_effort_type_id(best_effort_name)
        best_effort_name.tr!("-", " ")
        best_effort_type = BestEffortType.where(name: best_effort_name).first_or_create
        best_effort_type.save!
        best_effort_type.id
      end

      def create_activity(activity_json) # rubocop:disable AbcSize, MethodLength
        activity_id = activity_json["id"]
        athlete_id = activity_json["athlete"]["id"]
        Rails.logger.info("ActivityCreator - Creating or updating activity #{activity_id} for athlete #{athlete_id}.")

        activity = Activity.where(id: activity_id).first_or_create
        activity.name = activity_json["name"]
        activity.athlete_id = athlete_id
        activity.description = activity_json["description"]
        activity.distance = activity_json["distance"].to_f
        activity.moving_time = activity_json["moving_time"].to_i
        activity.elapsed_time = activity_json["elapsed_time"].to_i
        activity.total_elevation_gain = activity_json["total_elevation_gain"]
        activity.elev_high = activity_json["elev_high"]
        activity.elev_low = activity_json["elev_low"]
        activity.start_date = DateTime.parse(activity_json["start_date"])
        activity.start_date_local = DateTime.parse(activity_json["start_date_local"])
        activity.timezone = activity_json["timezone"]
        activity.athlete_count = activity_json["athlete_count"]
        activity.trainer = activity_json["trainer"]
        activity.commute = activity_json["commute"]
        activity.manual = activity_json["manual"]
        activity.private = activity_json["private"]
        activity.device_name = activity_json["device_name"]
        activity.flagged = activity_json["flagged"]
        activity.workout_type_id = activity_json["workout_type"].to_i
        activity.average_speed = activity_json["average_speed"]
        activity.max_speed = activity_json["max_speed"]
        activity.average_cadence = activity_json["average_cadence"]
        activity.average_temp = activity_json["average_temp"]
        activity.has_heartrate = activity_json["has_heartrate"]
        activity.average_heartrate = activity_json["average_heartrate"]
        activity.max_heartrate = activity_json["max_heartrate"]
        activity.calories = activity_json["calories"]
        activity.suffer_score = activity_json["suffer_score"] unless activity_json["suffer_score"].blank?
        activity.gear_id = activity_json["gear_id"]
        activity.save!
      end

      def create_best_effort(activity_json, best_effort_json)
        entity = BestEffort.where(id: best_effort_json["id"]).first_or_create
        entity.activity_id = activity_json["id"]
        entity.athlete_id = activity_json["athlete"]["id"]
        entity.pr_rank = best_effort_json["pr_rank"]
        entity.best_effort_type_id = get_best_effort_type_id(best_effort_json["name"])
        entity.distance = best_effort_json["distance"]
        entity.moving_time = best_effort_json["moving_time"]
        entity.elapsed_time = best_effort_json["elapsed_time"]
        entity.start_date = parse_date_time(best_effort_json["start_date"])
        entity.start_date_local = parse_date_time(best_effort_json["start_date_local"])
        entity.save!
      end

      def create_race(activity_json)
        race_distance = RaceDistance.find_by_actual_distance(activity_json["distance"].to_f)
        return if race_distance.nil?

        Rails.logger.info("ActivityCreator - Creating or updating race of distance '#{race_distance.name}' "\
          "for activity #{activity_json['id']} - '#{activity_json['name']}'.")
        race = Race.where(activity_id: activity_json["id"]).first_or_create
        race.athlete_id = activity_json["athlete"]["id"]
        race.race_distance = race_distance
        race.save!
      end

      def parse_date_time(date_time)
        DateTime.parse(date_time) unless date_time.blank?
      end
    end
  end
end
