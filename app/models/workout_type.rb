class WorkoutType < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true

  has_many :activities

  after_save    :expire_cache
  after_destroy :expire_cache

  def expire_cache
    Rails.cache.delete(CacheKeys::ALL_WORKOUT_TYPES)
  end

  def self.all_cached
    Rails.cache.fetch(CacheKeys::ALL_WORKOUT_TYPES) { all.to_a }
  end
end
