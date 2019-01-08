require "rails_helper"

RSpec.describe "RaceDistances", type: :request do
  describe "GET /race_distances" do
    it "should be successful" do
      # arrange.
      url = "/#{API_ROOT_PATH}/race_distances"
      expected = "#{EXPECTED_FOLDER}#{url}.json"

      # act.
      get url

      # assert.
      expect(response).to have_http_status(:success)
      expect(response.body).to eq(File.read(expected))
    end
  end
end
