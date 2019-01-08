require "rails_helper"

RSpec.describe "BestEffortTypes", type: :request do
  describe "GET /best_effort_types" do
    it "should be successful" do
      # arrange.
      url = "/#{API_ROOT_PATH}/best_effort_types"
      expected = "#{EXPECTED_FOLDER}#{url}.json"

      # act.
      get url

      # assert.
      expect(response).to have_http_status(:success)
      expect(response.body).to eq(File.read(expected))
    end
  end
end
