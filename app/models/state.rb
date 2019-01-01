class State < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: { scope: :country_id }

  belongs_to :country, foreign_key: "country_id"

  has_many :athlete_infos
end
