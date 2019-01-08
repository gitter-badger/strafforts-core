module Creators
  class HeartRateZonesCreator
    DEFAULT_ZONE_1_MAX = 123
    DEFAULT_ZONE_2_MAX = 153
    DEFAULT_ZONE_3_MAX = 169
    DEFAULT_ZONE_4_MAX = 184

    @heart_rate_zones = nil

    class << self
      def create_or_update(athlete_id, athlete_zones = nil?)
        if athlete_id.blank?
          Rails.logger.warn("HeartRateZonesCreator - Athlete ID is blank. Exiting...")
          return
        end

        Rails.logger.info("HeartRateZonesCreator - Creating or updating heart rate zones for athlete #{athlete_id}.")
        @heart_rate_zones = HeartRateZones.where(athlete_id: athlete_id).first_or_create
        create_default_heart_rate_zones

        create_heart_rate_zones_from_athlete_zones_hash(athlete_zones) unless athlete_zones.blank?

        @heart_rate_zones.save!
      end

      private

      def create_default_heart_rate_zones
        @heart_rate_zones.custom_zones = true
        @heart_rate_zones.zone_1_min = 0
        @heart_rate_zones.zone_1_max = DEFAULT_ZONE_1_MAX
        @heart_rate_zones.zone_2_min = DEFAULT_ZONE_1_MAX
        @heart_rate_zones.zone_2_max = DEFAULT_ZONE_2_MAX
        @heart_rate_zones.zone_3_min = DEFAULT_ZONE_2_MAX
        @heart_rate_zones.zone_3_max = DEFAULT_ZONE_3_MAX
        @heart_rate_zones.zone_4_min = DEFAULT_ZONE_3_MAX
        @heart_rate_zones.zone_4_max = DEFAULT_ZONE_4_MAX
        @heart_rate_zones.zone_5_min = DEFAULT_ZONE_4_MAX
        @heart_rate_zones.zone_5_max = -1
        @heart_rate_zones
      end

      def create_heart_rate_zones_from_athlete_zones_hash(athlete_zones) # rubocop:disable AbcSize
        @heart_rate_zones.custom_zones = athlete_zones["heart_rate"]["custom_zones"]
        @heart_rate_zones.zone_1_min = athlete_zones["heart_rate"]["zones"][0]["min"]
        @heart_rate_zones.zone_1_max = athlete_zones["heart_rate"]["zones"][0]["max"]
        @heart_rate_zones.zone_2_min = athlete_zones["heart_rate"]["zones"][1]["min"]
        @heart_rate_zones.zone_2_max = athlete_zones["heart_rate"]["zones"][1]["max"]
        @heart_rate_zones.zone_3_min = athlete_zones["heart_rate"]["zones"][2]["min"]
        @heart_rate_zones.zone_3_max = athlete_zones["heart_rate"]["zones"][2]["max"]
        @heart_rate_zones.zone_4_min = athlete_zones["heart_rate"]["zones"][3]["min"]
        @heart_rate_zones.zone_4_max = athlete_zones["heart_rate"]["zones"][3]["max"]
        @heart_rate_zones.zone_5_min = athlete_zones["heart_rate"]["zones"][4]["min"]
        @heart_rate_zones.zone_5_max = athlete_zones["heart_rate"]["zones"][4]["max"]
      end
    end
  end
end
