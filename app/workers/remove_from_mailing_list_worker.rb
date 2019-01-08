require "mailer_lite_api_wrapper"

class RemoveFromMailingListWorker
  include Sidekiq::Worker
  sidekiq_options queue: "critical", backtrace: true, retry: 0

  def perform(athlete_id, athlete_email)
    ::MailerLiteApiWrapper.new.remove_from_group(athlete_id, athlete_email) unless ENV["MAILER_LITE_API_KEY"].blank?
  end
end
