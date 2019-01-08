require "rails_helper"

RSpec.describe "WorkoutTypes", type: :request do
  describe "GET /workout_types" do
    it "should be successful" do
      # arrange.
      url = "/#{API_ROOT_PATH}/workout_types"
      expected = "#{EXPECTED_FOLDER}#{url}.json"

      # act.
      get url

      # assert.
      expect(response).to have_http_status(:success)
      expect(response.body).to eq(File.read(expected))
    end
  end
end
