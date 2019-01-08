module Creators
  class AthleteCreator
    @athlete = nil
    @athlete_info = nil

    class << self
      # On OAuth token exchange, a summary JSON is returned from Strava.
      # Otherwise, a detailed JSON will be retrieved for athletes.
      def create_or_update(access_token, athlete_hash, is_detailed) # rubocop:disable MethodLength
        if athlete_hash["id"].blank?
          Rails.logger.warn("AthleteCreator - Athlete ID is blank. Exiting...")
          return
        end

        athlete_id = athlete_hash["id"]

        @athlete = Athlete.find_by(id: athlete_id)
        if @athlete.nil?
          Rails.logger.info("AthleteCreator - Creating athlete #{athlete_id}.")

          @athlete = Athlete.new
          @athlete.id = athlete_id
          @athlete.is_public = true # Set profile to true by default when it's a new athlete.
        else
          Rails.logger.info("AthleteCreator - Updating athlete #{athlete_id}.")
        end

        @athlete_info = AthleteInfo.find_by(athlete_id: athlete_id)
        if @athlete_info.nil?
          Rails.logger.info("AthleteCreator - Creating athlete info for athlete #{athlete_id}.")

          @athlete_info = AthleteInfo.new
          @athlete_info.athlete_id = athlete_id
        else
          Rails.logger.info("AthleteCreator - Updating athlete info for athlete #{athlete_id}.")
        end

        update_athlete_summary(access_token, athlete_hash)
        update_athlete_details(athlete_hash) if is_detailed
        update_athlete_location(athlete_hash)

        @athlete.save!
        @athlete_info.save!
        @athlete
      end

      private

      def update_athlete_summary(access_token, athlete_hash)
        @athlete.access_token = access_token
        @athlete.is_active = true

        unless athlete_hash["email"].blank?
          @athlete.email = athlete_hash["email"]
          @athlete.email_confirmed = true
          @athlete.confirmed_at = Time.now.utc
          @athlete.confirmation_token = nil
        end

        @athlete_info.username = athlete_hash["username"]
        @athlete_info.firstname = athlete_hash["firstname"]
        @athlete_info.lastname = athlete_hash["lastname"]
        @athlete_info.profile_medium = athlete_hash["profile_medium"]
        @athlete_info.profile = athlete_hash["profile"]
        @athlete_info.sex = athlete_hash["sex"]
        @athlete_info.created_at = athlete_hash["created_at"]
        @athlete_info.updated_at = athlete_hash["updated_at"]
      end

      def update_athlete_details(athlete_hash)
        @athlete_info.follower_count = athlete_hash["follower_count"]
        @athlete_info.friend_count = athlete_hash["friend_count"]
        @athlete_info.athlete_type = athlete_hash["athlete_type"]
        @athlete_info.date_preference = athlete_hash["date_preference"]
        @athlete_info.measurement_preference = athlete_hash["measurement_preference"]
        @athlete_info.weight = athlete_hash["weight"]
      end

      def update_athlete_location(athlete_hash)
        country_id = Creators::LocationCreator.create_country(athlete_hash["country"])
        state_id = Creators::LocationCreator.create_state(country_id, athlete_hash["state"])
        city_id = Creators::LocationCreator.create_city(country_id, athlete_hash["city"])
        @athlete_info.country_id = country_id unless country_id.blank?
        @athlete_info.state_id = state_id unless state_id.blank?
        @athlete_info.city_id = city_id unless city_id.blank?
      end
    end
  end
end
