namespace :fetch do
  desc "Fetch the latest data for all athletes"
  # Usage: docker-compose run web bundle exec rails fetch:latest PRO_ONLY=[true/false]
  task latest: :environment do
    fetch("latest", ENV["PRO_ONLY"])
  end

  desc "Fetch all data for all athletes"
  # Usage: docker-compose run web bundle exec rails fetch:all PRO_ONLY=[true/false]
  task all: :environment do
    fetch("all", ENV["PRO_ONLY"])
  end

  desc "Fetch best efforts for all athletes."
  # Usage: docker-compose run web bundle exec rails fetch:best_efforts MODE=[all/latest] PRO_ONLY=[true/false]
  task best_efforts: :environment do
    fetch(ENV["MODE"], ENV["PRO_ONLY"], %w[best-efforts])
  end

  desc "Fetch personal bests for all athletes."
  # Usage: docker-compose run web bundle exec rails fetch:personal_bests MODE=[all/latest] PRO_ONLY=[true/false]
  task personal_bests: :environment do
    fetch(ENV["MODE"], ENV["PRO_ONLY"], %w[personal-bests])
  end

  desc "Fetch races for all athletes."
  # Usage: docker-compose run web bundle exec rails fetch:races MODE=[all/latest] PRO_ONLY=[true/false]
  task races: :environment do
    fetch(ENV["MODE"], ENV["PRO_ONLY"], %w[races])
  end

  def fetch(mode, pro_only = false, type = nil)
    athletes = Athlete.find_all_by_is_active(true)
    athletes.each_with_index do |athlete, index|
      if pro_only == "true"
        athlete = AthleteDecorator.decorate(athlete)
        next unless athlete.pro_subscription?
      end

      begin
        access_token = ::Creators::RefreshTokenCreator.refresh(athlete.access_token)
        FetchActivityWorker.set(queue: :low).perform_in((index * 3).seconds, access_token, mode: mode, type: type)
      rescue StandardError => e
        Rails.logger.error("Rake 'fetch' failed. #{e.message}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
        next
      end
    end
  end
end
