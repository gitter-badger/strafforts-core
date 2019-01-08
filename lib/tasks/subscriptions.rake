namespace :subscriptions do
  desc "Automatically renew due subscriptions."
  # Usage: docker-compose run web bundle exec rails subscriptions:renew
  task renew: :environment do
    RenewSubscriptionsWorker.perform_async
  end
end
