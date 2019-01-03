require "rails_helper"

RSpec.describe Api::V1::MetaController, type: :request do
  let(:expected_folder) { "./spec/requests/expected".freeze }

  describe "GET index" do
    it "should not find athlete by id who does not exist" do
      expect { get "/#{API_ROOT_PATH}/athletes/987654321/meta" }
        .to raise_error(ActionController::RoutingError, "Could not find the requested athlete '987654321' by id.")
    end

    it "should be successful for an existing athlete" do
      # arrange.
      url = "/#{API_ROOT_PATH}/athletes/9123806/meta"
      expected = "#{expected_folder}#{url}.json"

      # act.
      get url

      # assert.
      expect(response).to have_http_status(:success)
      FileHelpers.write_expected_file(expected, response.body)
      expect(response.body).to eq(File.read(expected))
    end
  end
end
