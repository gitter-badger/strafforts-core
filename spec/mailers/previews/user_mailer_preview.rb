# Preview all emails at http://localhost:5000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def email_address_confirmation
    athlete = Athlete.find_by_id(17142380)
    UserMailer.email_address_confirmation(athlete)
  end
end
