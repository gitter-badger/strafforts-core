require "rails_helper"

RSpec.describe AthleteDecorator, type: :decorator do
  DEFAULT_NAME = "Strava User".freeze

  let(:athlete_id) { "98765" }
  let(:athlete) { FactoryBot.build(:athlete, id: athlete_id) }

  it "should be the same entity after decorating" do
    # act.
    decorated_athlete = AthleteDecorator.decorate(athlete).object

    # assert.
    expect(decorated_athlete).to eq(athlete)
  end

  describe ".profile_url" do
    it "should be the correct profile_url when athlete.id is not blank" do
      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.profile_url).to eq("https://www.strava.com/athletes/#{athlete_id}")
    end
  end

  describe ".profile_image_url" do
    it "should be nil when athlete.profile is an invalid url" do
      # arrange.
      athlete.athlete_info.profile = "strafforts/@\#$%^&*()"
      athlete.athlete_info.save!

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.profile_image_url).to be_nil
    end

    it "should be the correct profile_image_url when athlete.athlete_info.profile is a valid url" do
      # arrange.
      PROFILE_URL = "https://www.tonystark.com/large.jpg".freeze
      athlete = FactoryBot.build(:athlete, id: athlete_id)
      athlete.athlete_info.profile = PROFILE_URL
      athlete.athlete_info.save!

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.profile_image_url).to eq(PROFILE_URL)
    end
  end

  describe ".pro_subscription?" do
    it "should be true for athlete with PRO subscriptions" do
      # arrange.
      athlete = Athlete.find_by(id: 9123806)

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.pro_subscription?).to be true
    end

    it "should be false for athlete with already deleted PRO subscriptions" do
      # arrange.
      athlete = Athlete.find_by(id: 222)

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.pro_subscription?).to be false
    end

    it "should be false for athlete without PRO subscriptions" do
      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.pro_subscription?).to be false
    end
  end

  describe ".pro_subscription" do
    it "should return a subscription for athlete with PRO subscriptions" do
      # arrange.
      athlete = Athlete.find_by(id: 9123806)

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.pro_subscription.is_a?(Subscription)).to be true
      expect(decorator.pro_subscription.expires_at).not_to be_nil
    end

    it "should return nil for athlete with only deleted PRO subscriptions" do
      # arrange.
      athlete = Athlete.find_by(id: 222)

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.pro_subscription).to be nil
    end

    it "should return the correct subscription for athlete with indefinite PRO subscriptions" do
      # act.
      athlete = Athlete.find_by(id: 333)

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.pro_subscription.is_a?(Subscription)).to be true
      expect(decorator.pro_subscription.expires_at).to be nil
    end

    it "should return nil for athlete without PRO subscriptions" do
      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.pro_subscription).to be nil
    end
  end

  describe ".pro_subscription_expires_at_formatted" do
    it "should be indefinite for athlete with Lifetime PRO subscriptions" do
      # arrange.
      athlete = Athlete.find_by(id: 333)

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.pro_subscription_expires_at_formatted).to eq("Indefinite")
    end

    it "should be the correct date for athlete with ordinary PRO subscriptions" do
      # arrange.
      athlete = Athlete.find_by(id: 9123806)

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.pro_subscription_expires_at_formatted).to eq("2028/03/15")
    end

    it "should be nil for athlete with already deleted PRO subscriptions" do
      # arrange.
      athlete = Athlete.find_by(id: 222)

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.pro_subscription_expires_at_formatted).to be nil
    end

    it "should be nil for athlete without PRO subscriptions" do
      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.pro_subscription_expires_at_formatted).to be nil
    end
  end

  describe ".pro_subscription_plan" do
    it "should return a subscription plan for athlete with PRO subscriptions" do
      # arrange.
      athlete = Athlete.find_by(id: 9123806)

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.pro_subscription_plan.is_a?(SubscriptionPlan)).to be true
    end

    it "should return nil for athlete with only deleted PRO subscriptions" do
      # arrange.
      athlete = Athlete.find_by(id: 222)

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.pro_subscription_plan).to be nil
    end

    it "should return the correct subscription plan for athlete with indefinite PRO subscriptions" do
      # arrange.
      athlete = Athlete.find_by(id: 333)

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.pro_subscription_plan.is_a?(SubscriptionPlan)).to be true
      expect(decorator.pro_subscription_plan.name).to eq("Lifetime PRO")
    end

    it "should return nil for athlete without PRO subscriptions" do
      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.pro_subscription_plan).to be nil
    end
  end

  describe ".following_url" do
    it "should be the correct following_url when athlete.id is not blank" do
      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.following_url).to eq("https://www.strava.com/athletes/#{athlete_id}/follows?type=following")
    end
  end

  describe ".follower_url" do
    it "should be the correct follower_url when athlete.id is not blank" do
      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.follower_url).to eq("https://www.strava.com/athletes/#{athlete_id}/follows?type=followers")
    end
  end

  describe ".fullname" do
    it "should be '#{DEFAULT_NAME}' when both athlete.firstname and athlete.lastname are blank" do
      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.fullname).to eq(DEFAULT_NAME)
    end

    it "should be the correct fullname when both athlete.firstname and athlete.lastname are not blank" do
      # arrange.
      athlete.athlete_info.firstname = "Tony"
      athlete.athlete_info.lastname = "Stark"
      athlete.athlete_info.save!

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.fullname).to eq("Tony Stark")
    end

    it "should be the firstname when only athlete.firstname is not blank" do
      # arrange.
      athlete.athlete_info.firstname = "Tony"
      athlete.athlete_info.save!

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.fullname).to eq("Tony")
    end

    it "should be the lastname when only athlete.lastname is not blank" do
      # arrange.
      athlete.athlete_info.lastname = "Stark"
      athlete.athlete_info.save!

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.fullname).to eq("Stark")
    end
  end

  describe ".display_name" do
    context "when fullname is under length limit" do
      it "should be the fullname" do
        # arrange.
        athlete.athlete_info.firstname = "Tony"
        athlete.athlete_info.lastname = "Stark"
        athlete.athlete_info.save!

        # act.
        decorator = AthleteDecorator.decorate(athlete)

        # assert.
        expect(decorator.display_name).to eq("Tony Stark")
      end
    end

    context "when fullname is over length limit" do
      let(:athlete) { Athlete.find_by(id: 9123806) }

      it "should be the firstname when the athlete has firstname" do
        # arrange.
        athlete.athlete_info.firstname = "Veryveryveryveryverylongname"
        athlete.athlete_info.lastname = nil
        athlete.athlete_info.save!

        # act.
        decorator = AthleteDecorator.decorate(athlete)

        # assert.
        expect(decorator.display_name).to eq("Veryveryveryveryverylongname")
      end

      it "should be the lastname when the athlete has only lastname" do
        # arrange.
        athlete.athlete_info.firstname = nil
        athlete.athlete_info.lastname = "Veryveryveryveryverylongname"
        athlete.athlete_info.save!

        # act.
        decorator = AthleteDecorator.decorate(athlete)

        # assert.
        expect(decorator.display_name).to eq("Veryveryveryveryverylongname")
      end
    end
  end

  describe ".location" do
    context "when athlete.city and athlete.country are both nil" do
      it 'should be ""' do
        # arrange.
        athlete = Athlete.find_by(id: 9123806)
        athlete.athlete_info.city = nil
        athlete.athlete_info.country = nil

        # act.
        decorator = AthleteDecorator.decorate(athlete)

        # assert.
        expect(decorator.location).to eq("")
      end
    end

    context "when one of athlete.city and athlete.country is nil" do
      let(:athlete) { Athlete.find_by(id: 9123806) }

      it "should be country name when athlete.city is nil but not athlete.country" do
        # arrange.
        athlete.athlete_info.city = nil

        # act.
        decorator = AthleteDecorator.decorate(athlete)

        # assert.
        expect(decorator.location).to eq("New Zealand")
      end

      it "should be city name when athlete.country is nil but not athlete.city" do
        # arrange.
        athlete.athlete_info.country = nil

        # act.
        decorator = AthleteDecorator.decorate(athlete)

        # assert.
        expect(decorator.location).to eq("Christchurch")
      end
    end

    context "when both athlete.city and athlete.country are not nil" do
      let(:athlete) { Athlete.find_by(id: 9123806) }

      it 'should be "" when both athlete.city.name and athlete.country.name are blank' do
        # arrange.
        athlete.athlete_info.city.name = nil
        athlete.athlete_info.country.name = nil

        # act.
        decorator = AthleteDecorator.decorate(athlete)

        # assert.
        expect(decorator.location).to eq("")
      end

      it "should be the country name when athlete.city.name is blank" do
        # arrange.
        athlete.athlete_info.city.name = nil

        # act.
        decorator = AthleteDecorator.decorate(athlete)

        # assert.
        expect(decorator.location).to eq("New Zealand")
      end

      it "should be the city name when athlete.country.name is blank" do
        # arrange.
        athlete.athlete_info.country.name = nil

        # act.
        decorator = AthleteDecorator.decorate(athlete)

        # assert.
        expect(decorator.location).to eq("Christchurch")
      end

      it "should be the city and country name when neither athlete.country.name and athlete.city.name is blank" do
        # act.
        decorator = AthleteDecorator.decorate(athlete)

        # assert.
        expect(decorator.location).to eq("Christchurch, New Zealand")
      end
    end
  end

  describe ".display_location" do
    context "when location is under length limit" do
      it "should be the location" do
        # arrange.
        athlete = Athlete.find_by(id: 9123806)

        # act.
        decorator = AthleteDecorator.decorate(athlete)

        # assert.
        expect(decorator.display_location).to eq("Christchurch, New Zealand")
      end
    end

    context "when location is over length limit" do
      let(:athlete) { Athlete.find_by(id: 9123806) }

      it "should be the city name when athlete.city.name is not blank" do
        # arrange.
        athlete.athlete_info.country.name = "The United States of America"

        # act.
        decorator = AthleteDecorator.decorate(athlete)

        # assert.
        expect(decorator.display_location).to eq("Christchurch")
      end

      it "should be the country name when athlete.country.name is not blank" do
        # arrange.
        athlete.athlete_info.city = nil
        athlete.athlete_info.country.name = "The United States of America"

        # act.
        decorator = AthleteDecorator.decorate(athlete)

        # assert.
        expect(decorator.display_location).to eq("The United States of America")
      end
    end
  end

  describe ".friend_count" do
    it 'should be "0" when athlete.friend_count is nil' do
      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.friend_count).to eq("0")
    end

    it "should be the correct friend_count when athlete.friend_count is not blank" do
      # arrange.
      athlete.athlete_info.friend_count = 100
      athlete.athlete_info.save!

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.friend_count).to eq("100")
    end
  end

  describe ".follower_count" do
    it 'should be "0" when athlete.follower_count is blank' do
      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.follower_count).to eq("0")
    end

    it "should be the correct follower_count when athlete.follower_count is not blank" do
      # arrange.
      athlete.athlete_info.follower_count = 999
      athlete.athlete_info.save!

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.follower_count).to eq("999")
    end
  end

  describe ".heart_rate_zones" do
    it "should be the default heart rate zones when athlete.id matches nothing" do
      # arrange.
      athlete = FactoryBot.build(:athlete, id: 99999)

      # act.
      decorator = AthleteDecorator.decorate(athlete)
      puts athlete.heart_rate_zones.inspect

      # assert.
      expect(decorator.heart_rate_zones.zone_1_max).to eq(123)
      expect(decorator.heart_rate_zones.zone_2_max).to eq(153)
      expect(decorator.heart_rate_zones.zone_3_max).to eq(169)
    end

    it "should be the correct heart rate zones for an athlete matching the provided athlete.id" do
      # arrange.
      athlete = FactoryBot.build(:athlete_with_heart_rate_zones, id: athlete_id)

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.heart_rate_zones.zone_1_max).to eq(140)
      expect(decorator.heart_rate_zones.zone_2_max).to eq(150)
      expect(decorator.heart_rate_zones.zone_3_max).to eq(160)
    end
  end

  describe ".returning_after_inactivity?" do
    it "should be true when athlete.last_active_at is more than 180 days ago" do
      # arrange.
      athlete = FactoryBot.build(:athlete, id: athlete_id, last_active_at: Time.now - 365.days)

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.returning_after_inactivity?).to eq(true)
    end

    it "should be false when athlete.last_active_at is less than 180 days ago" do
      # arrange.
      athlete = FactoryBot.build(:athlete, id: athlete_id, last_active_at: Time.now - 1.day)

      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.returning_after_inactivity?).to eq(false)
    end

    it "should be true when athlete.last_active_at is nil" do
      # act.
      decorator = AthleteDecorator.decorate(athlete)

      # assert.
      expect(decorator.returning_after_inactivity?).to eq(false)
    end
  end
end
