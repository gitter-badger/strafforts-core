require "date"

class MailerLiteApiWrapper
  def initialize
    @api_client = MailerLite::Client.new(api_key: ENV["MAILER_LITE_API_KEY"])
    @group_id = ENV["MAILER_LITE_GROUP_ID"]
  end

  def remove_from_group(athlete_id, athlete_email)
    email = athlete_email.downcase
    @api_client.delete_group_subscriber(@group_id, email)
  rescue StandardError => e
    Rails.logger.warn("MailerLiteApiWrapper - "\
      "Removing athlete '#{athlete_id} - #{email}' from group '#{@group_id}' failed. "\
      "#{e.message}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
  end

  def subscribe_to_group(athlete)
    athlete = athlete.decorate
    email = athlete.email.downcase

    subscriber = {
      email: athlete.email.downcase,
      name: athlete.athlete_info.firstname,
      fields: create_merge_fields(athlete)
    }
    @api_client.create_group_subscriber(@group_id, subscriber)
  rescue StandardError => e
    Rails.logger.warn("MailerLiteApiWrapper - "\
      "Subscribing athlete '#{athlete.id} - #{email}' to group '#{@group_id}' failed. "\
      "#{e.message}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
  end

  private

  def create_merge_fields(athlete)
    athlete = athlete.decorate

    city = athlete.athlete_info.city.nil? ? nil : athlete.athlete_info.city.name.to_s.strip
    country = athlete.athlete_info.country.nil? ? nil : athlete.athlete_info.country.name.to_s.strip

    pro_expires_at = athlete.pro_subscription_expires_at_formatted
    pro_expiration_date = nil
    unless pro_expires_at.blank?
      pro_expiration_date = "Indefinite".casecmp(pro_expires_at).zero? ? "2999/12/31" : pro_expires_at
    end

    {
      email: athlete.email.downcase,
      name: athlete.athlete_info.firstname,
      last_name: athlete.athlete_info.lastname,
      country: country,
      city: city,
      athlete_id: athlete.id.to_s,
      profile_url: "#{Settings.app.production_url}/athletes/#{athlete.id}",
      strava_profile_url: "#{Settings.strava.url}/athletes/#{athlete.id}",
      join_date: athlete.created_at.strftime("%Y/%m/%d"),
      last_active_date: Time.now.utc.to_date.strftime("%Y/%m/%d"),
      pro_expiry_date: pro_expiration_date
    }
  end
end
