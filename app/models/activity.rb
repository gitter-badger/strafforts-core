class Activity < ApplicationRecord
  validates :athlete_id,
            :name,
            :distance,
            :moving_time,
            :elapsed_time,
            :start_date,
            :start_date_local,
            :workout_type_id,
            presence: true

  belongs_to :athlete, foreign_key: "athlete_id"
  belongs_to :gear, foreign_key: "gear_id", optional: true
  belongs_to :workout_type, foreign_key: "workout_type_id"

  has_many :best_efforts
  has_one :race
end
