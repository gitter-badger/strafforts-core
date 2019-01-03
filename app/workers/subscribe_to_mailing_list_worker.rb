require "mailer_lite_api_wrapper"

class SubscribeToMailingListWorker
  include Sidekiq::Worker
  sidekiq_options queue: "critical", backtrace: true

  def perform(athlete_id)
    athlete = Athlete.find(athlete_id)
    ::MailerLiteApiWrapper.new.subscribe_to_group(athlete) unless ENV["MAILER_LITE_API_KEY"].blank?
  end
end
