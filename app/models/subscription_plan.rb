class SubscriptionPlan < ApplicationRecord
  validates :name, :description, :amount, :amount_per_month, presence: true

  has_many :subscriptions

  after_save    :expire_cache
  after_destroy :expire_cache

  def expire_cache
    Rails.cache.delete(CacheKeys::ALL_SUBSCRIPTION_PLANS)
  end

  def self.all_cached
    Rails.cache.fetch(CacheKeys::ALL_SUBSCRIPTION_PLANS) { all.to_a }
  end
end
