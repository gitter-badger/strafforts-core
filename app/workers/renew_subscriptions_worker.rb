class RenewSubscriptionsWorker
  include Sidekiq::Worker
  sidekiq_options queue: "low", backtrace: true, retry: 0

  def perform
    renewed_ids = []
    athletes = Athlete.find_all_by_is_active(true)
    athletes.each do |athlete|
      athlete = AthleteDecorator.decorate(athlete)
      subscription = athlete.pro_subscription
      subscription_plan = athlete.pro_subscription_plan

      next if subscription.nil? # Athlete has no PRO subscriptions.
      next if subscription.cancel_at_period_end # Athlete has opted out of auto-renewal.
      next unless subscription.expires_at.today? # Only to continue if it expires today.

      stripe_customer = StripeCustomer.find_by(athlete_id: athlete.id)
      next if stripe_customer.nil? # There's no StripeCustomer reference. Most likely to be a free subscription gifted, instead of previously purchased by athletes.

      ::StripeApiWrapper.renew(stripe_customer, subscription_plan)
      ::Creators::SubscriptionCreator.create(athlete, subscription_plan.name)

      renewed_ids << athlete.id
    rescue StandardError => e
      Rails.logger.error("Renewing subscription failed for athlete '#{athlete.id}'. "\
        "#{e.message}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
      next
    end
    Rails.logger.warn("[subscriptions:renew] - "\
      "A total of #{renewed_ids.count} athletes have been renewed: #{renewed_ids.join(',')}")
  end
end
