module Creators
  class LocationCreator
    def self.create_country(country)
      return if country.blank?

      Rails.logger.info("LocationCreator - Creating or updating country '#{country}'.")
      country = Country.where(name: country).first_or_create
      country.id
    end

    def self.create_state(country_id, state)
      return if country_id.blank?

      Rails.logger.info("LocationCreator - Creating or updating state '#{state}'.")
      state = State.where(name: state, country_id: country_id).first_or_create
      state.id
    end

    def self.create_city(country_id, city)
      return if country_id.blank?

      Rails.logger.info("LocationCreator - Creating or updating city '#{city}'.")
      city = City.where(name: city, country_id: country_id).first_or_create
      city.id
    end
  end
end
