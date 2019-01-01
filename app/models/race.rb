class Race < ApplicationRecord
  validates :activity_id, :athlete_id, :race_distance_id, presence: true

  belongs_to :activity, foreign_key: "activity_id"
  belongs_to :athlete, foreign_key: "athlete_id"
  belongs_to :race_distance, foreign_key: "race_distance_id"
end
