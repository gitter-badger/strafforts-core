class UserMailer < ApplicationMailer
  def email_address_confirmation(athlete)
    return if athlete.nil?

    @athlete_name = format_athlete_fullname(athlete.athlete_info.firstname, athlete.athlete_info.lastname)
    return if @athlete_name.blank? || athlete.email.blank?

    @app_url = Settings.app.production_url
    @sender_name = Settings.app.emailer.default_sender_name
    @sender_email = Settings.app.emailer.default_sender_email
    @subject = "Hi #{@athlete_name}! Strafforts needs to verify your email address."
    @verify_email_link = "#{Settings.app.base_url}/auth/verify-email/#{athlete.confirmation_token}"

    mail(
      from: "#{@sender_name} <#{@sender_email}>",
      to: "#{@athlete_name} <#{athlete.email}>",
      subject: @subject
    )

    athlete.confirmation_sent_at = Time.now.utc
    athlete.save!
  end

  private

  def format_athlete_fullname(firstname, lastname)
    return "New Athlete" if firstname.blank? && lastname.blank?
    return firstname if !firstname.blank? && firstname.length > 1

    "#{firstname} #{lastname}".to_s.strip
  end
end
