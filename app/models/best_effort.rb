class BestEffort < ApplicationRecord
  validates :activity_id, :athlete_id, :best_effort_type_id, presence: true
  validates :distance, :moving_time, :elapsed_time, presence: true

  belongs_to :activity, foreign_key: "activity_id"
  belongs_to :athlete, foreign_key: "athlete_id"
  belongs_to :best_effort_type, foreign_key: "best_effort_type_id"
end
