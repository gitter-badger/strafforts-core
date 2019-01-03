class Api::V1::AthletesController < ApplicationController
  before_action :find_athlete, :require_current_user
  before_action :require_pro_subscription, only: %i[fetch_latest reset_profile]

  def submit_email
    email_address = params[:email]
    if email_address.blank?
      Rails.logger.warn("Could not confirm email for an empty email.")
      render json: { error: Messages::EMAIL_EMPTY }.to_json, status: 400
      return
    end

    begin
      # Reset the email confirmation.
      @athlete.email = email_address
      @athlete.email_confirmed = false
      @athlete.confirmed_at = nil
      @athlete.confirmation_token = SecureRandom.urlsafe_base64.to_s if @athlete.confirmation_token.blank?
      @athlete.confirmation_sent_at = nil
      @athlete.save!

      # Send the confirmation email.
      UserMailer.email_address_confirmation(@athlete).deliver_now

      render json: {}, status: 200
    rescue StandardError => e
      Rails.logger.error("AthletesController - Could not confirm email address '#{params[:email]}'. "\
          "#{e.message}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
      render json: { error: Messages::EMAIL_SENDING_FAILURE }.to_json, status: 500
      return
    end
  end

  def fetch_latest
    access_token = ::Creators::RefreshTokenCreator.refresh(@athlete.access_token)

    # Fetch the latest data for this athlete.
    FetchActivityWorker.perform_async(access_token)
  rescue StandardError => e
    Rails.logger.error("AthletesController - Could not fetch latest. "\
        "#{e.message}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
  end

  def subscribe_to_pro
    plan_id = params[:subscriptionPlanId]
    subscription_plan = SubscriptionPlan.find_by(id: plan_id)
    if subscription_plan.nil?
      Rails.logger.warn("AthletesController - Could not find the requested subscription plan '#{plan_id}'.")
      render json: { error: Messages::PRO_PLAN_NOT_FOUND }.to_json, status: 404
      return
    end

    begin
      @athlete = @athlete.decorate
      ::StripeApiWrapper.charge(@athlete, subscription_plan, params[:stripeToken], params[:stripeEmail])
      ::Creators::SubscriptionCreator.create(@athlete, subscription_plan.name)
    rescue Stripe::StripeError => e
      Rails.logger.error("AthletesController - StripeError while subscribing to PRO plan for athlete '#{@athlete.id}'. "\
          "Status: #{e.http_status}. Message: #{e.json_body.blank? ? '' : e.json_body[:error][:message]}\n"\
          "Backtrace:\n\t#{e.backtrace.join("\n\t")}")
      render json: { error: "#{Messages::STRIPE_ERROR} #{e.json_body.blank? ? '' : e.json_body[:error][:message]}" }.to_json, status: 402
      return
    rescue StandardError => e
      Rails.logger.error("AthletesController - Subscribing to PRO plan '#{subscription_plan.name}' failed for athlete '#{@athlete.id}'. "\
          "#{e.message}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
      render json: { error: Messages::PAYMENT_FAILED }.to_json, status: 500
      return
    end
  end

  def reset_profile
    athlete_id = @athlete.id

    if params[:is_hard_reset].to_s == "true"
      # Delete all activity data except for the athlete itself.
      BestEffort.where(athlete_id: athlete_id).destroy_all
      Race.where(athlete_id: athlete_id).destroy_all
      Activity.where(athlete_id: athlete_id).destroy_all
      Rails.logger.warn("Hard resetting all activity data for athlete #{athlete_id}.")
    else
      Rails.logger.warn("Soft resetting all activity data for athlete #{athlete_id}.")
    end

    # Set last_activity_retrieved to nil for this athlete.
    @athlete.update(last_activity_retrieved: nil, total_run_count: 0)

    begin
      access_token = ::Creators::RefreshTokenCreator.refresh(@athlete.access_token)

      # Fetch all data for this athlete.
      FetchActivityWorker.perform_async(access_token, mode: "all")
    rescue StandardError => e
      Rails.logger.error("AthletesController - Could not reset profile for athlete '#{athlete_id}'. "\
          "#{e.message}\nBacktrace:\n\t#{e.backtrace.join("\n\t")}")
    end
  end

  def save_profile
    is_public = params[:is_public].blank? || params[:is_public]
    @athlete.update(is_public: is_public)
  end

  private

  def find_athlete
    @athlete = Athlete.find_by(id: params[:id])

    return unless @athlete.nil?

    Rails.logger.warn("AthletesController - Could not perform action for an athlete '#{params[:id]}' that could not be found.")
    render json: { error: Messages::ATHLETE_NOT_FOUND }.to_json, status: 404
  end

  def require_current_user
    @is_current_user = @athlete.access_token == cookies.signed[:access_token]

    return if @is_current_user

    Rails.logger.warn("AthletesController - Could not perform action for an athlete #{@athlete.id} that is not the currently logged in.")
    render json: { error: Messages::ATHLETE_NOT_ACCESSIBLE }.to_json, status: 403
  end

  def require_pro_subscription
    @athlete = @athlete.decorate

    return if @athlete.pro_subscription?

    render json: { error: Messages::PRO_ACCOUNTS_ONLY }.to_json, status: 403
  end
end
