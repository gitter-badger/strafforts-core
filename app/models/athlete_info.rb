class AthleteInfo < ApplicationRecord
  belongs_to :athlete, foreign_key: "athlete_id"

  belongs_to :city, foreign_key: "city_id", optional: true
  belongs_to :state, foreign_key: "state_id", optional: true
  belongs_to :country, foreign_key: "country_id", optional: true
end
