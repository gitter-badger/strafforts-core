require "rails_helper"

RSpec.describe "FaqCategories", type: :request do
  describe "GET /faq_categories" do
    it "should be successful" do
      # arrange.
      url = "/#{API_ROOT_PATH}/faq_categories"
      expected = "#{EXPECTED_FOLDER}#{url}.json"

      # act.
      get url

      # assert.
      expect(response).to have_http_status(:success)
      expect(response.body).to eq(File.read(expected))
    end
  end
end
