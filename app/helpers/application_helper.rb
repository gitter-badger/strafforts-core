require "ostruct"

module ApplicationHelper
  class Helper
    MAX_DISTANCES_TO_SHOW = 4
    MAX_ITEM_ALLOWED_PER_DISTANCE = 5

    @major_best_effort_types = ["Marathon", "Half Marathon", "10k", "5k"]
    @other_best_effort_types = ["50k", "30k", "20k", "10 mile", "15k", "2 mile", "1 mile", "1k", "1/2 mile", "400m"]
    @major_race_distances = ["Marathon", "Half Marathon", "10k", "5k"]
    @other_race_distances = ["100 miles", "100k", "50 miles", "50k", "20k", "15k", "3000m", "1 mile", "Other Distances"]

    class << self
      # This shapes BestEffort entities retrieved from DB into the form needed in the view.
      def shape_best_efforts(entities, heart_rate_zones, measurement_unit)
        shape_entities(entities, heart_rate_zones, measurement_unit, true)
      end

      # This shapes Race entities retrieved from DB into races needed in the view.
      def shape_races(race_entities, heart_rate_zones, measurement_unit)
        shape_entities(race_entities, heart_rate_zones, measurement_unit, false)
      end

      def all_best_effort_types
        best_effort_types = major_best_effort_types
        best_effort_types.concat(other_best_effort_types)
        best_effort_types
      end

      def all_race_distances
        race_distances = major_race_distances
        race_distances.concat(other_race_distances)
        race_distances
      end

      def major_best_effort_types
        create_item_array(@major_best_effort_types, true)
      end

      def other_best_effort_types
        create_item_array(@other_best_effort_types, false)
      end

      def major_race_distances
        create_item_array(@major_race_distances, true)
      end

      def other_race_distances
        create_item_array(@other_race_distances, false)
      end

      def get_heart_rate_zones(athlete_id)
        heart_rate_zones = HeartRateZones.find_by_athlete_id(athlete_id)
        return create_default_heart_rate_zones if heart_rate_zones.nil?

        heart_rate_zones
      end

      def find_items_to_show_in_overview(item_type, items) # rubocop:disable CyclomaticComplexity
        is_type_of_pb = item_type == ItemTypes::PERSONAL_BESTS
        is_type_of_races = item_type == ItemTypes::RACES

        results = {}

        if is_type_of_pb
          major_distances = ApplicationHelper::Helper.major_best_effort_types
          other_distances = ApplicationHelper::Helper.other_best_effort_types
        end
        if is_type_of_races
          major_distances = ApplicationHelper::Helper.major_race_distances
          other_distances = ApplicationHelper::Helper.other_race_distances
        end

        has_major_distance_items = false
        major_distances.each do |distance|
          activities = find_activities_by_distance(items, distance[:name])
          unless activities.empty?
            results[distance[:name]] = activities
            has_major_distance_items = true
          end
        end

        # Fill in with other distances when there are not enough major distances.
        unless has_major_distance_items
          other_distances.each do |distance|
            activities = find_activities_by_distance(items, distance[:name])
            unless activities.empty?
              results[distance[:name]] = activities if results.count < MAX_DISTANCES_TO_SHOW
            end
          end
        end

        results
      end

      private

      def calculate_total_elevation_gain(total_elevation_gain, is_imperial_unit)
        return "" if total_elevation_gain.blank?
        return (total_elevation_gain * 3.28084).to_i if is_imperial_unit # Convert to feet from meters.

        total_elevation_gain.to_i
      end

      # Use exactly the same logic as app/javascript/common/helpers.ts, instead of Ruby's divmod.
      def convert_to_pace(average_speed, is_imperial_unit)
        return "" if average_speed.blank? || average_speed.to_i.zero?

        total_seconds = is_imperial_unit ? (1609.344 / average_speed) : (1000 / average_speed)

        hours = (total_seconds / 3600).floor
        minutes = ((total_seconds - (hours * 3600)) / 60).floor
        seconds = (total_seconds - (hours * 3600) - (minutes * 60)).ceil

        hours_text = hours.zero? ? "" : hours.to_s
        minutes_text = "#{minutes}:"
        seconds_text = seconds < 10 ? "0#{seconds}" : seconds.to_s
        if seconds == 60
          minutes_text = "#{(minutes + 1)}:"
          seconds_text = "00"
        end
        "#{hours_text}#{minutes_text}#{seconds_text}"
      end

      def convert_to_pace_in_seconds(average_speed, is_imperial_unit)
        return 0 if average_speed.blank? || average_speed.to_i.zero?

        is_imperial_unit ? (1609.344 / average_speed) : (1000 / average_speed)
      end

      def create_default_heart_rate_zones
        heart_rate_zones = OpenStruct.new(custom_zones: false)
        heart_rate_zones.zone_1_min = 0
        heart_rate_zones.zone_1_max = 123
        heart_rate_zones.zone_2_min = 123
        heart_rate_zones.zone_2_max = 153
        heart_rate_zones.zone_3_min = 153
        heart_rate_zones.zone_3_max = 169
        heart_rate_zones.zone_4_min = 169
        heart_rate_zones.zone_4_max = 184
        heart_rate_zones.zone_5_min = 184
        heart_rate_zones.zone_5_max = -1
        heart_rate_zones
      end

      def find_activities_by_distance(items, distance)
        activities = items.select do |item|
          if !item[:best_effort_type].blank?
            distance.casecmp(item[:best_effort_type]).zero?
          elsif !item[:race_distance].blank?
            distance.casecmp(item[:race_distance]).zero?
          end
        end
        activities.take(MAX_ITEM_ALLOWED_PER_DISTANCE)
      end

      def get_heart_rate_zone(heart_rate_zones, heart_rate) # rubocop:disable AbcSize, CyclomaticComplexity, PerceivedComplexity, LineLength
        if heart_rate_zones.nil? ||
           heart_rate_zones.zone_1_min.blank? || heart_rate_zones.zone_1_max.blank? ||
           heart_rate_zones.zone_2_min.blank? || heart_rate_zones.zone_2_max.blank? ||
           heart_rate_zones.zone_3_min.blank? || heart_rate_zones.zone_3_max.blank? ||
           heart_rate_zones.zone_4_min.blank? || heart_rate_zones.zone_4_max.blank? ||
           heart_rate_zones.zone_5_min.blank? || heart_rate_zones.zone_5_max.blank?
          heart_rate_zones = create_default_heart_rate_zones
        end

        if heart_rate.blank? || heart_rate == -1
          "na"
        elsif heart_rate < heart_rate_zones.zone_1_max
          "1"
        elsif heart_rate.between?(heart_rate_zones.zone_1_max, heart_rate_zones.zone_2_max)
          "2"
        elsif heart_rate.between?(heart_rate_zones.zone_2_max, heart_rate_zones.zone_3_max)
          "3"
        elsif heart_rate.between?(heart_rate_zones.zone_3_max, heart_rate_zones.zone_4_max)
          "4"
        elsif heart_rate > heart_rate_zones.zone_4_max
          "5"
        end
      end

      def shape_entities(entities, heart_rate_zones, measurement_unit, is_type_of_best_efforts) # rubocop:disable AbcSize, CyclomaticComplexity, PerceivedComplexity, LineLength
        shaped_items = []

        return shaped_items if entities.blank?

        entities.each do |entity| # rubocop:disable BlockLength
          item = {}

          # Must have an activity associated in order to show.
          next if entity.activity.nil?

          item[:is_imperial_unit] = measurement_unit == "feet"
          if is_type_of_best_efforts
            next if entity.best_effort_type.nil?

            item[:best_effort_type_id] = entity.best_effort_type.id
            item[:best_effort_type] = entity.best_effort_type.name
            item[:elapsed_time] = entity.elapsed_time

            average_speed = 0
            unless entity.distance.nil? || entity.elapsed_time.nil? || entity.elapsed_time.zero?
              average_speed = entity.distance / entity.elapsed_time
            end
          else
            next if entity.race_distance.nil?

            item[:race_distance] = entity.race_distance.name
            item[:elapsed_time] = entity.activity.elapsed_time

            # Convert distance from meters to miles/km.
            distance = item[:is_imperial_unit] ? entity.activity.distance * 0.000621371 : entity.activity.distance * 0.001
            item[:distance] = distance
            item[:distance_unit] = item[:is_imperial_unit] ? "miles" : "km"
            average_speed = entity.activity.average_speed
          end

          item[:activity_id] = entity.activity.id
          item[:activity_name] = entity.activity.name
          item[:start_date] = get_date_time(entity.activity.start_date_local)
          item[:workout_type_name] = entity.activity.workout_type.nil? ? "n/a" : entity.activity.workout_type.name
          item[:elapsed_time_formatted] = Time.at(item[:elapsed_time]).utc.strftime("%H:%M:%S")
          item[:pace_in_seconds] = convert_to_pace_in_seconds(average_speed, item[:is_imperial_unit])
          item[:pace] = convert_to_pace(average_speed, item[:is_imperial_unit])
          item[:pace_unit] = item[:is_imperial_unit] ? "/mi" : "/km"
          item[:elevation] = calculate_total_elevation_gain(entity.activity.total_elevation_gain, item[:is_imperial_unit])
          item[:elevation_unit] = item[:is_imperial_unit] ? "ft" : "m"
          item[:cadence] = entity.activity.average_cadence.nil? ? "" : (entity.activity.average_cadence * 2).to_i
          item[:suffer_score] = entity.activity.suffer_score.nil? ? "" : entity.activity.suffer_score.to_i
          item[:gear_name] = entity.activity.gear.nil? ? "Unspecified" : entity.activity.gear.name
          item[:average_heartrate] = entity.activity.average_heartrate.nil? ? -1 : entity.activity.average_heartrate.to_i
          item[:average_hr_zone] = get_heart_rate_zone(heart_rate_zones, item[:average_heartrate])
          item[:max_heartrate] = entity.activity.max_heartrate.nil? ? -1 : entity.activity.max_heartrate.to_i
          item[:max_hr_zone] = get_heart_rate_zone(heart_rate_zones, item[:max_heartrate])

          shaped_items << item
        end

        # Sort by start_date (not id) with the latest first.
        shaped_items.sort_by! { |shaped_item| [shaped_item[:start_date], -shaped_item[:elapsed_time]] }.reverse!
        shaped_items
      end

      def create_item_array(types, is_major)
        results = []
        types.each do |name|
          item = { name: name, is_major: is_major }
          results << item
        end
        results
      end

      def get_date_time(date_time)
        date_time.nil? ? "" : date_time.to_s.slice(0, 10)
      end
    end
  end
end
