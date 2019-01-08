require "rails_helper"

RSpec.describe Api::V1::AthletesController, type: :request do
  let(:athlete_id) { "9123806" }
  let(:url) { "/#{API_ROOT_PATH}/athletes/#{athlete_id}/submit-email" }

  describe "POST submit-email" do
    TEST_ACCESS_TOKEN = "4d5cf2bbc714a4e22e309cf5fcf15e40".freeze
    TEST_EMAIL = "bruce.banner+123@avengers.com".freeze

    it "should return 404 when the requested athlete does not exist" do
      post "/#{API_ROOT_PATH}/athletes/987654321/submit-email"
      expect(response).to have_http_status(404)
    end

    it "should return 403 when requested athlete is not the current user" do
      setup_cookie(nil)
      post url, params: { email: TEST_EMAIL }
      expect(response).to have_http_status(403)
    end

    it "should return 400 when email is blank" do
      setup_cookie(TEST_ACCESS_TOKEN)
      post url
      expect(response).to have_http_status(400)
    end

    it "should return 400 when email is invalid" do
      # arrange.
      setup_cookie(TEST_ACCESS_TOKEN)

      # act.
      post url, params: { email: "invalid@example" }

      # assert.
      expect(response).to have_http_status(500)
    end

    it "should confirm the email" do
      # arrange.
      setup_cookie(TEST_ACCESS_TOKEN)

      # act.
      post url, params: { email: TEST_EMAIL }

      # assert.
      expect(response).to have_http_status(:success)

      athlete = Athlete.find_by(id: 9123806)
      expect(athlete).not_to be_nil
      expect(athlete.email).to eq(TEST_EMAIL)
      expect(athlete.email_confirmed).to be false
      expect(athlete.confirmed_at).to be nil
      expect(athlete.confirmation_token).not_to be_nil
      expect(athlete.confirmation_sent_at).not_to be_nil
    end
  end
end
