module Creators
  class SubscriptionCreator
    def self.cancel(athlete)
      athlete = AthleteDecorator.decorate(athlete)

      subscription = athlete.pro_subscription
      subscription.cancel_at_period_end = true
      subscription.save!
    end

    def self.create(athlete, subscription_plan_name) # rubocop:disable AbcSize, CyclomaticComplexity
      subscription_plan = SubscriptionPlan.find_by(name: subscription_plan_name)
      raise "Subscription plan '#{subscription_plan_name}' cannot be found." if subscription_plan.blank?

      athlete = AthleteDecorator.decorate(athlete)
      has_lifetime_pro = athlete.pro_subscription? && athlete.pro_subscription.expires_at.blank?
      raise "The athlete is already on Lifetime PRO plan." if has_lifetime_pro

      # Find out the new starts_at time for the new subscription.
      # If the current subscription has not expired yet, new starts_at should be the existing expiry time.
      # Otherwise, starts from now.
      currently_valid_to = athlete.pro_subscription? ? athlete.pro_subscription.expires_at : nil
      new_starts_at = currently_valid_to.nil? || currently_valid_to < Time.now.utc ? Time.now.utc : currently_valid_to

      # Set all existing subscriptions to inactive.
      existing_subscriptions = Subscription.where(athlete_id: athlete.id, is_deleted: false)
      existing_subscriptions.each do |subscription|
        subscription.is_active = false
        subscription.save!
      end

      # Create a new subscription.
      subscription = Subscription.new
      subscription.athlete_id = athlete.id
      subscription.subscription_plan_id = subscription_plan.id
      subscription.starts_at = new_starts_at
      subscription.expires_at = new_starts_at + subscription_plan.duration.days
      subscription.is_deleted = false
      subscription.is_active = true
      subscription.cancel_at_period_end = false
      subscription.save!
    end
  end
end
