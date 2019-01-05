class Api::V1::AuthController < ApplicationController
  before_action :set_athlete, only: [:deauthorize]

  # POST auth/login
  def login # rubocop:disable AbcSize
    request_body = request.body

    access_token = request_body[:access_token]
    athlete = ::Creators::AthleteCreator.create_or_update(access_token, request_body[:athlete], false)

    begin
      ::Creators::RefreshTokenCreator.create(access_token, request_body[:refresh_token], request_body[:expires_at])
    rescue StandardError => e
      Rails.logger.error("RefreshTokenCreator - Creation failed. "\
          "#{e.message}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
      raise
    end

    ::Creators::HeartRateZonesCreator.create_or_update(request_body[:athlete][:id]) # Create default heart rate zones.

    if ENV["ENABLE_OLD_MATES_PRO_ON_LOGIN"].present?
      begin
        athlete = athlete.decorate
        ::Creators::SubscriptionCreator.create(athlete, "Old Mates PRO") if !athlete.pro_subscription? && athlete.returning_after_inactivity?
      rescue StandardError => e
        Rails.logger.error("Automatically applying 'Old Mates PRO' failed for athlete '#{athlete.id}'. "\
            "#{e.message}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
        raise
      end
    end

    # Fetch data for this athlete.
    FetchActivityWorker.set(retry: true).perform_async(access_token)

    encryptor = ActiveSupport::MessageEncryptor.new(ENV["ENCRYPTION_KEY"])
    access_token = encryptor.encrypt_and_sign(access_token)
    render json: { access_token: access_token }, status: 200
  end

  # POST auth/deauthorize
  def deauthorize
    # Reset total count first.
    # Just in case that worker doesn't run causing next fetch (if reconnected) to skip.
    @athlete.total_run_count = 0
    @athlete.save!

    DeauthorizeAthleteWorker.perform_async(@access_token)

    render json: {}, status: 200
  end

  # GET auth/confirm-email/:token
  def confirm_email
    athlete = Athlete.find_by(confirmation_token: params[:token])
    if athlete.nil?
      Rails.logger.warn(Messages::EMAIL_VERIFICATION_TOKEN_NOT_FOUND)

      render json: { error: Messages::EMAIL_VERIFICATION_TOKEN_NOT_FOUND }.to_json, status: 404
      return
    end

    athlete.email_confirmed = true
    athlete.confirmed_at = Time.now.utc
    athlete.confirmation_token = nil
    athlete.save!

    # Subscribe or update to mailing list.
    SubscribeToMailingListWorker.perform_async(athlete.id)

    render json: {}, status: 200
  end

  private

  def set_athlete
    encryption_key = Rails.application.credentials.access_token_encryption_key
    encryptor = ActiveSupport::MessageEncryptor.new(encryption_key)
    @access_token = encryptor.decrypt_and_verify(request.headers["Authorization"])

    @athlete = Athlete.find_by(access_token: @access_token)
    return unless @athlete.nil?

    render json: { error: Messages::ATHLETE_NOT_FOUND }.to_json, status: 404
  end
end
