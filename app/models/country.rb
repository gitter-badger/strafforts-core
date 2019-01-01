class Country < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true

  has_many :athlete_infos
  has_many :cities
  has_many :states
end
