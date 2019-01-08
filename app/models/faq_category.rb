class FaqCategory < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true

  has_many :faqs

  after_save    :expire_cache
  after_destroy :expire_cache

  def expire_cache
    Rails.cache.delete(CacheKeys::ALL_FAQ_CATEGORIES)
  end

  def self.all_cached
    Rails.cache.fetch(CacheKeys::ALL_FAQ_CATEGORIES) { all.to_a }
  end
end
