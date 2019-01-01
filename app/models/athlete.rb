class Athlete < ApplicationRecord
  validates :access_token, presence: true
  validates :is_active, :is_public, :email_confirmed, inclusion: { in: [true, false] }
  validates_format_of :email, allow_nil: true, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/

  has_one :athlete_info
  has_one :stripe_customer

  has_many :activities
  has_many :best_efforts
  has_many :gears
  has_many :heart_rate_zones
  has_many :races
  has_many :subscriptions

  before_create :generate_confirmation_token

  def self.find_all_by_is_active(is_active = true)
    results = where("is_active = ?", is_active).order("updated_at")
    results.empty? ? [] : results
  end

  def self.find_by_email(email)
    results = where("lower(email) = ?", email.downcase)
    results.empty? ? nil : results.take
  end

  def destroy_all_data
    BestEffort.where(athlete_id: id).destroy_all
    Race.where(athlete_id: id).destroy_all
    Gear.where(athlete_id: id).destroy_all
    HeartRateZones.where(athlete_id: id).destroy_all
    Activity.where(athlete_id: id).destroy_all
    AthleteInfo.where(athlete_id: id).destroy_all
    Subscription.where(athlete_id: id).update_all(is_deleted: true)
    Athlete.where(id: id).destroy_all
    Rails.logger.info("Destroying all data for athlete '#{id}' completed.")
  end

  private

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64(32).to_s if confirmation_token.blank?
  end
end
