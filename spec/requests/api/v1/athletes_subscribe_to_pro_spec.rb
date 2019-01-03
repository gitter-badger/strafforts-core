require "rails_helper"

RSpec.describe Api::V1::AthletesController, type: :request do
  let(:expected_folder) { "./spec/requests/expected".freeze }
  let(:athlete_id) { "9123806" }
  let(:url) { "/#{API_ROOT_PATH}/athletes/#{athlete_id}/subscribe-to-pro" }

  describe "POST subscribe-to-pro" do
    it "should return 404 when the requested subscription plan does not exist" do
      setup_cookie("4d5cf2bbc714a4e22e309cf5fcf15e40")
      post url, params: { subscriptionPlanId: "11111-aaaa-bbbb-2222-1111111111" }
      expect(response).to have_http_status(404)
    end

    it "should return 404 when the requested athlete does not exist" do
      post "/#{API_ROOT_PATH}/athletes/987654321/subscribe-to-pro"
      expect(response).to have_http_status(404)
    end

    it "should return 403 when requested athlete is not the current user" do
      setup_cookie(nil)
      post url, params: { subscriptionPlanId: "a543d5df-9e40-41a3-9e19-55255652ce0b" }
      expect(response).to have_http_status(403)
    end

    it "should return 402 when Stripe throws an error" do
      setup_cookie("4d5cf2bbc714a4e22e309cf5fcf15e40")
      post url, params: { subscriptionPlanId: "a543d5df-9e40-41a3-9e19-55255652ce0b" }
      expect(response).to have_http_status(402)
    end
  end
end
