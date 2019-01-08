class AthleteDecorator < Draper::Decorator
  delegate_all

  STRAVA_URL = Settings.strava.url
  MAX_INFO_TEXT_LENGTH = 25

  def profile_url
    return "#{STRAVA_URL}/athletes/#{object.id}" unless object.id.blank?

    nil
  end

  def profile_image_url
    object.athlete_info.profile if valid_url?(object.athlete_info.profile)
  end

  def pro_subscription?
    !pro_subscription.nil?
  end

  def pro_subscription
    subscription = Subscription.find_by(athlete_id: object.id, is_deleted: false, is_active: true)
    return nil if subscription.nil?

    return subscription if subscription.expires_at.nil? # Indefinite PRO subscription.

    subscription.expires_at < Time.now.utc ? nil : subscription # Subscription must has not expired yet.
  end

  def pro_subscription_expires_at_formatted
    if pro_subscription?
      return "Indefinite" if pro_subscription.expires_at.blank?

      return pro_subscription.expires_at.strftime("%Y/%m/%d")
    end
    nil
  end

  def pro_subscription_plan
    return nil unless pro_subscription?

    pro_subscription.subscription_plan
  end

  def following_url
    return "#{profile_url}/follows?type=following" unless object.id.blank?

    nil
  end

  def follower_url
    return "#{profile_url}/follows?type=followers" unless object.id.blank?

    nil
  end

  def fullname
    if object.athlete_info.firstname.blank? && object.athlete_info.lastname.blank?
      "Strava User"
    else
      "#{object.athlete_info.firstname} #{object.athlete_info.lastname}".to_s.strip
    end
  end

  def display_name
    return fullname unless fullname.length > MAX_INFO_TEXT_LENGTH
    return object.athlete_info.firstname unless object.athlete_info.firstname.blank?

    object.athlete_info.lastname unless object.athlete_info.lastname.blank?
  end

  def location # rubocop:disable AbcSize, CyclomaticComplexity, PerceivedComplexity
    return "" if object.athlete_info.city.nil? && object.athlete_info.country.nil?
    return object.athlete_info.country.name.to_s.strip if object.athlete_info.city.nil?
    return object.athlete_info.city.name.to_s.strip if object.athlete_info.country.nil?

    return "" if object.athlete_info.city.name.blank? && object.athlete_info.country.name.blank?
    return object.athlete_info.country.name.to_s.strip if object.athlete_info.city.name.blank?
    return object.athlete_info.city.name.to_s.strip if object.athlete_info.country.name.blank?

    "#{object.athlete_info.city.name.to_s.strip}, #{object.athlete_info.country.name.to_s.strip}"
  end

  def display_location # rubocop:disable AbcSize
    return location unless location.length > MAX_INFO_TEXT_LENGTH
    return object.athlete_info.city.name unless object.athlete_info.city.nil? || object.athlete_info.city.name.blank?

    object.athlete_info.country.name unless object.athlete_info.country.nil? || object.athlete_info.country.name.blank?
  end

  def friend_count
    if object.athlete_info.friend_count.blank?
      "0"
    else
      object.athlete_info.friend_count.to_s.strip
    end
  end

  def follower_count
    if object.athlete_info.follower_count.blank?
      "0"
    else
      object.athlete_info.follower_count.to_s.strip
    end
  end

  def heart_rate_zones
    ApplicationHelper::Helper.get_heart_rate_zones(object.id)
  end

  def returning_after_inactivity?
    return false if athlete.last_active_at.blank?

    inactivity_days_threshold = ENV["INACTIVITY_DAYS_THRESHOLD"].blank? ? 180 : ENV["INACTIVITY_DAYS_THRESHOLD"].to_i
    athlete.last_active_at.to_date < Date.today - inactivity_days_threshold.days
  end

  private

  def valid_url?(string)
    uri = URI.parse(string)
    %w[http https ftp].include?(uri.scheme)
  rescue URI::InvalidURIError
    false
  end
end
