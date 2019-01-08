require "rails_helper"

RSpec.describe Api::V1::BestEffortsController, type: :request do
  describe "GET index" do
    it "should be 404 when the requested athlete does not exist" do
      get "/#{API_ROOT_PATH}/athletes/987654321/best-efforts"
      expect(response).to have_http_status(404)
    end

    it "should be a 404 with an invalid distance" do
      get "/#{API_ROOT_PATH}/athletes/9123806/best-efforts/100m"
      expect(response).to have_http_status(404)
    end

    it "should be empty when best effort type is not specified" do
      get "/#{API_ROOT_PATH}/athletes/9123806/best-efforts"
      expect(response.body).to eq("[]")
    end

    context "should be successful" do
      distances = BestEffortType.all
      distances.each do |distance|
        it "for best effort type '#{distance.name}'" do
          # arrange.
          url = "/#{API_ROOT_PATH}/athletes/9123806/best-efforts/#{distance.name.tr('/', '_')}"
          expected = "#{EXPECTED_FOLDER}#{url}.json"

          # act.
          get URI.encode(url)

          # assert.
          expect(response).to have_http_status(:success)
          FileHelpers.write_expected_file(expected, response.body)
          expect(response.body).to eq(File.read(expected))
        end
      end
    end
  end

  describe "GET top_one_by_year" do
    it "should be 404 when the requested athlete does not exist" do
      get "/#{API_ROOT_PATH}/athletes/987654321/best-efforts/10k/top-one-by-year"
      expect(response).to have_http_status(404)
    end

    it "should be a 404 with an invalid distance" do
      get "/#{API_ROOT_PATH}/athletes/9123806/best-efforts/100m/top-one-by-year"
      expect(response).to have_http_status(404)
    end

    it "should be empty when best effort type is not specified" do
      get "/#{API_ROOT_PATH}/athletes/9123806/best-efforts"
      expect(response.body).to eq("[]")
    end

    context "should be successful" do
      distances = BestEffortType.all
      distances.each do |distance|
        it "for best effort type '#{distance.name}'" do
          # act.
          get URI.encode("/#{API_ROOT_PATH}/athletes/9123806/best-efforts/#{distance.name.tr('/', '_')}/top-one-by-year")

          # assert.
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
