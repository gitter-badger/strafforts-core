require "yaml"

namespace :athletes do
  desc "Grant PRO plan to the given athletes."
  # Usage: docker-compose run web bundle exec rails athletes:apply_pro PLAN="Old Mates PRO" ID=[Comma Separated list]
  task apply_pro: :environment do
    apply_subscription(ENV["PLAN"], ENV["ID"])
  end

  desc "Delete all data associated with athletes who have been inactive for more 180 days + 7 days of grace period."
  # Usage: docker-compose run web bundle exec rails athletes:clean_up
  task clean_up: :environment do
    CleanUpInactiveAthletesWorker.perform_async
  end

  desc "Delete all data associated with athletes in the given comma separated email/id list."
  # Usage: docker-compose run web bundle exec rails athletes:destroy EMAIL=[Comma Separated list] ID=[Comma Separated list] DRY_RUN=[true/false]
  # Only to destroy when DRY_RUN is explicitly set to false.
  task destroy: :environment do
    counter = 0
    is_dry_run = ENV["DRY_RUN"].blank? || ENV["DRY_RUN"] != "false"

    emails = ENV["EMAIL"].blank? ? [] : ENV["EMAIL"].split(",")
    emails.each do |email|
      next if email.blank?

      athlete_info = AthleteInfo.find_by_email(email)
      next if athlete_info.nil?

      athlete = Athlete.find_by(id: athlete_info.athlete_id)
      next if athlete.nil?

      athlete_id = athlete.id
      if is_dry_run
        puts "[DRY_RUN] Destroying all data for athlete #{athlete_id} (#{email})."
      else
        puts "Destroying all data for athlete #{athlete_id} (#{email})."
        athlete.destroy_all_data
        counter += 1
      end
    end

    ids = ENV["ID"].blank? ? [] : ENV["ID"].split(",")
    ids.each do |athlete_id|
      next if athlete_id.blank?

      athlete = Athlete.where(id: athlete_id).take
      next if athlete.nil?

      athlete_email = athlete.email
      if is_dry_run
        puts "[DRY_RUN] Destroying all data for athlete #{athlete_id} (#{athlete_email})."
      else
        puts "Destroying all data for athlete #{athlete_id} (#{athlete_email})."
        athlete.destroy_all_data
        counter += 1
      end
    end

    puts "Rake task 'athlete:destroy' completed. A total of #{counter} athletes destroyed."
  end

  desc "Fetch data for athletes in the given comma separated email/id list."
  # Usage: docker-compose run web bundle exec rails athletes:fetch MODE=[all/latest] ID=[Comma Separated list]
  task fetch: :environment do
    ids = ENV["ID"].blank? ? [] : ENV["ID"].split(",")
    ids.each do |athlete_id|
      next if athlete_id.blank?

      athlete = Athlete.find_by(id: athlete_id)
      if athlete.nil?
        puts "Athlete '#{athlete_id}' was not found."
      else
        begin
          access_token = ::Creators::RefreshTokenCreator.refresh(athlete.access_token)
          FetchActivityWorker.perform_async(access_token, mode: ENV["MODE"])
        rescue StandardError => e
          Rails.logger.error("Rake 'athletes:fetch' failed. #{e.message}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
          next
        end
      end
    end
  end

  def apply_subscription(subscription_plan_name, id_list)
    counter = 0
    ids = id_list.blank? ? [] : id_list.split(",")
    ids.each do |athlete_id|
      next if athlete_id.blank?

      athlete = Athlete.find_by(id: athlete_id)
      if athlete.nil?
        puts "Athlete '#{athlete_id}' was not found."
      else
        ::Creators::SubscriptionCreator.create(athlete, subscription_plan_name)
        counter += 1
      end
    end
    puts "A total of #{counter} athletes have been applied to."
  end
end
