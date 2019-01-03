require "rails_helper"

RSpec.describe Api::V1::AthletesController, type: :request do
  let(:athlete_id) { "98765" }
  let(:url) { "/#{API_ROOT_PATH}/athletes/#{athlete_id}/fetch-latest" }

  describe "POST fetch-latest" do
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
      it "should be 403 even with the correct cookie" do
        # arrange.
        athlete = FactoryBot.build(:athlete, id: athlete_id)
        setup_cookie(athlete.access_token)

        # act.
        post url

        # assert.
        expect(response).to have_http_status(403)
      end
    end

    context "for an athlete with PRO subscription" do
      it "should fetch-latest successfully with the correct cookie" do
        # arrange.
        access_token = "4d5cf2bbc714a4e22e309cf5fcf15e40"
        token_refresh_request_body = create_refresh_token_request_body(access_token)

        setup_cookie(access_token)
        refresh_token_response_body = { access_token: access_token, refresh_token: "1234567898765432112345678987654321", expires_at: 1531385304 }.to_json
        stub_strava_post_request(Settings.strava.api_auth_token_url, token_refresh_request_body, 200, refresh_token_response_body)

        # act.
        post "/#{API_ROOT_PATH}/athletes/9123806/fetch-latest"

        # assert.
        expect(response).to have_http_status(:success)
      end
    end
  end
end
