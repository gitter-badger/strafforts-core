require "rails_helper"

RSpec.describe Api::V1::AthletesController, type: :request do
  describe "POST reset-profile" do
    let(:athlete_id) { "98765" }
    let(:url) { "/#{API_ROOT_PATH}/athletes/#{athlete_id}/reset-profile" }

    it "should return 404 when the requested athlete does not exist" do
      # act.
      post url

      # assert.
      expect(response).to have_http_status(404)
    end

    it "should return 403 when requested athlete is not the current user" do
      # arrange.
      FactoryBot.build(:athlete, id: athlete_id)

      # act.
      post url

      # assert.
      expect(response).to have_http_status(403)
    end

    context "for an athlete without PRO subscription" do
      it "should return 403 when soft reset-profile even with the correct cookie" do
        # arrange.
        athlete = FactoryBot.build(:athlete, id: athlete_id)
        setup_cookie(athlete.access_token)

        # act.
        post url

        # assert.
        expect(response).to have_http_status(403)
      end

      it "should return 403 when hard reset-profile even with the correct cookie" do
        # arrange.
        athlete = FactoryBot.build(:athlete, id: athlete_id)
        setup_cookie(athlete.access_token)

        # act.
        post url, params: { is_hard_reset: true }

        # assert.
        expect(response).to have_http_status(403)
      end
    end

    context "for an athlete with PRO subscription" do
      it "should soft reset-profile successfully with the correct cookie" do
        # arrange.
        access_token = "4d5cf2bbc714a4e22e309cf5fcf15e40"
        token_refresh_request_body = create_refresh_token_request_body(access_token)

        setup_cookie(access_token)
        refresh_token_response_body = {
          access_token: access_token,
          refresh_token: "1234567898765432112345678987654321",
          expires_at: 1531385304
        }.to_json
        stub_strava_post_request(Settings.strava.api_auth_token_url, token_refresh_request_body, 200, refresh_token_response_body)

        athlete = Athlete.find_by(id: 9123806)
        expect(athlete).not_to be_nil
        expect(athlete.last_activity_retrieved).not_to be_nil

        best_efforts = BestEffort.where(athlete_id: athlete.id)
        expect(best_efforts.count).to be > 0
        races = Race.where(athlete_id: athlete.id)
        expect(races.count).to be > 0
        activities = Activity.where(athlete_id: athlete.id)
        expect(activities.count).to be > 0

        # act.
        post "/#{API_ROOT_PATH}/athletes/9123806/reset-profile"

        # assert.
        athlete.reload
        expect(athlete.last_activity_retrieved).to be_nil

        best_efforts = BestEffort.where(athlete_id: athlete.id)
        expect(best_efforts.count).to be > 0
        races = Race.where(athlete_id: athlete.id)
        expect(races.count).to be > 0
        activities = Activity.where(athlete_id: athlete.id)
        expect(activities.count).to be > 0
      end

      it "should hard reset-profile successfully with the correct cookie" do
        # arrange.
        access_token = "4d5cf2bbc714a4e22e309cf5fcf15e40"
        token_refresh_request_body = create_refresh_token_request_body(access_token)

        setup_cookie(access_token)
        refresh_token_response_body = {
          access_token: access_token,
          refresh_token: "1234567898765432112345678987654321",
          expires_at: 1531385304
        }.to_json
        stub_strava_post_request(Settings.strava.api_auth_token_url, token_refresh_request_body, 200, refresh_token_response_body)

        athlete = Athlete.find_by(id: 9123806)
        expect(athlete).not_to be_nil
        expect(athlete.last_activity_retrieved).not_to be_nil

        best_efforts = BestEffort.where(athlete_id: athlete.id)
        expect(best_efforts.count).to be > 0
        races = Race.where(athlete_id: athlete.id)
        expect(races.count).to be > 0
        activities = Activity.where(athlete_id: athlete.id)
        expect(activities.count).to be > 0

        # act.
        post "/#{API_ROOT_PATH}/athletes/9123806/reset-profile", params: { is_hard_reset: true }

        # assert.
        athlete.reload
        expect(athlete.last_activity_retrieved).to be_nil

        best_efforts = BestEffort.where(athlete_id: athlete.id)
        expect(best_efforts.count).to be 0
        races = Race.where(athlete_id: athlete.id)
        expect(races.count).to be 0
        activities = Activity.where(athlete_id: athlete.id)
        expect(activities.count).to be 0
      end
    end
  end
end
