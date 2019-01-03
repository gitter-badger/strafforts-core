class DeauthorizeAthleteWorker
  include Sidekiq::Worker
  sidekiq_options queue: "critical", backtrace: true, retry: 0

  STRAVA_API_AUTH_DEAUTHORIZE_URL = Settings.strava.api_auth_deauthorize_url

  def perform(access_token)
    raise ArgumentError, "DeauthorizeAthleteWorker - Access token is blank." if access_token.blank?

    # Renew athlete's refresh token first.
    begin
      access_token = ::Creators::RefreshTokenCreator.refresh(access_token)
    rescue StandardError => e
      Rails.logger.error("Refreshing token while deauthorizing failed. "\
        "#{e.message}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
    end

    # Revoke Strava access.
    uri = URI(STRAVA_API_AUTH_DEAUTHORIZE_URL)
    response = Net::HTTP.post_form(uri, "access_token" => access_token)
    if response.is_a? Net::HTTPSuccess
      Rails.logger.info("Revoked Strava access for athlete (access_token=#{access_token}).")
    else
      # Fail to revoke Strava access. Log it and don't throw.
      Rails.logger.error("Revoking Strava access failed. HTTP Status Code: #{response.code}. "\
        "Response Message: #{response.message}")
    end

    # Delete all data.
    athlete = Athlete.find_by(access_token: access_token)
    return if athlete.nil?

    athlete_id = athlete.id
    Rails.logger.warn("Deauthorizing and destroying all data for athlete #{athlete_id}.")
    athlete.destroy_all_data
  end
end
