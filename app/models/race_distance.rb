class RaceDistance < ApplicationRecord
  validates :distance, presence: true
  validates :distance, uniqueness: true

  has_many :races

  after_save    :expire_cache
  after_destroy :expire_cache

  def expire_cache
    Rails.cache.delete(CacheKeys::ALL_RACE_DISTANCES)
    Rails.cache.delete(format(CacheKeys::RACE_DISTANCES, distance: name.downcase))
  end

  def self.all_cached
    Rails.cache.fetch(CacheKeys::ALL_RACE_DISTANCES) { all.to_a }
  end

  def self.find_by_actual_distance(actual_distance)
    all.each do |race_distance|
      distance = race_distance.distance
      next unless actual_distance.between?(distance * 0.975, distance * 1.05) # Allowed margin: 2.5% under or 5% over.

      return race_distance
    end
    # If no matching distance was found, find the default RaceDistance called 'Other Distances'.
    results = where(distance: 0)
    results.empty? ? nil : results.take
  end

  def self.find_by_name(distance_name)
    Rails.cache.fetch(format(CacheKeys::RACE_DISTANCES, distance: distance_name.downcase)) do
      results = where("lower(name) = ?", distance_name.downcase)
      results.empty? ? nil : results.take
    end
  end
end
