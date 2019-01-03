class CleanUpInactiveAthletesWorker
  include Sidekiq::Worker
  sidekiq_options queue: "low", backtrace: true, retry: 0

  def perform
    destroyed_ids = []
    inactive_athletes = Athlete.where("last_active_at < ?", Time.now.utc - 180.days - 7.days)
    inactive_athletes.each do |athlete|
      athlete = AthleteDecorator.decorate(athlete)
      next if athlete.pro_subscription?

      destroyed_ids << athlete.id
      athlete.destroy_all_data
    rescue StandardError => e
      Rails.logger.error("Cleaning up inactive athlete failed for athlete '#{athlete.id}'. "\
        "#{e.message}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
      next
    end
    Rails.logger.warn("[athlete:clean_up] - "\
      "A total of #{destroyed_ids.count} inactive athletes destroyed: #{destroyed_ids.join(',')}.")
  end
end
