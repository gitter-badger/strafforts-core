require "rails_helper"

RSpec.describe "Faqs", type: :request do
  describe "GET /faqs" do
    it "should be successful" do
      # arrange.
      url = "/#{API_ROOT_PATH}/faqs"
      expected = "#{EXPECTED_FOLDER}#{url}.json"

      # act.
      get url

      # assert.
      expect(response).to have_http_status(:success)
      expect(response.body).to eq(File.read(expected))
    end
  end

  describe "GET /faqs/:id" do
    it "should be successful" do
      # act.
      get "/#{API_ROOT_PATH}/faqs/1"

      # assert.
      expect(response).to have_http_status(:success)
    end
  end
end
