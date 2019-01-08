class Subscription < ApplicationRecord
  validates :athlete_id, :subscription_plan_id, :starts_at, presence: true

  validates :is_deleted, :is_active, :cancel_at_period_end, inclusion: { in: [true, false] }

  belongs_to :athlete, foreign_key: "athlete_id"
  belongs_to :subscription_plan, foreign_key: "subscription_plan_id"

  after_save    :expire_cache
  after_destroy :expire_cache

  def expire_cache
    Rails.cache.delete(format(CacheKeys::META, athlete_id: athlete_id))
  end

  def self.find_all_by_athlete_id(athlete_id, is_deleted = false)
    results = where("athlete_id = ?", athlete_id).where("is_deleted = ?", is_deleted)
    results.empty? ? [] : results
  end
end
