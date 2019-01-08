require "rails_helper"

RSpec.describe "SubscriptionPlans", type: :request do
  describe "GET /subscription_plans" do
    it "should be successful" do
      # arrange.
      url = "/#{API_ROOT_PATH}/subscription_plans"
      expected = "#{EXPECTED_FOLDER}#{url}.json"

      # act.
      get url

      # assert.
      expect(response).to have_http_status(:success)
      expect(response.body).to eq(File.read(expected))
    end
  end
end
