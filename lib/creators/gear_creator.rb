module Creators
  class GearCreator
    def self.create(access_token, athlete_id, gears)
      return if athlete_id.blank? || gears.blank?

      gears_json = JSON.parse(gears.to_json)
      gears_json.each do |gear_json|
        id = gear_json["id"]
        distance = gear_json["distance"]

        gear = Gear.find_by(gear_id: gear_json["id"])

        # Skip if the gear hasn't been used since last update.
        next unless gear.nil? || gear.distance.blank? || gear.distance != distance

        Rails.logger.info("GearCreator - Creating or updating gear #{id} for athlete #{athlete_id}.")

        # Call Strava API: to get detailed gear information.
        api_wrapper = StravaApiWrapper.new(access_token)
        detailed_gear_json = api_wrapper.retrieve_gear(id)

        gear = Gear.where(gear_id: id).first_or_create
        gear.athlete_id = athlete_id
        gear.name = gear_json["name"]
        gear.primary = detailed_gear_json["primary"]
        gear.brand_name = detailed_gear_json["brand_name"]
        gear.distance = detailed_gear_json["distance"]
        gear.model = detailed_gear_json["model_name"] # Avoid clash with reserved Rails model_name.
        gear.description = detailed_gear_json["description"]
        gear.save!
      end
    end
  end
end
