class Gear < ApplicationRecord
  validates :athlete_id, :name, :gear_id, presence: true
  validates :gear_id, uniqueness: true
  validates :primary, inclusion: { in: [true, false] }

  belongs_to :athlete, foreign_key: "athlete_id"

  has_many :activities
end
