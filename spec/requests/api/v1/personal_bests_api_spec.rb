require "rails_helper"

RSpec.describe Api::V1::PersonalBestsController, type: :request do
  describe "GET index" do
    it "should be 404 when the requested athlete does not exist" do
      get "/#{API_ROOT_PATH}/athletes/987654321/personal-bests"
      expect(response).to have_http_status(404)
    end

    it "should be a 404 with an invalid distance" do
      get "/#{API_ROOT_PATH}/athletes/9123806/personal-bests/100m"
      expect(response).to have_http_status(404)
    end

    it "should be empty when best effort type is not specified" do
      get "/#{API_ROOT_PATH}/athletes/9123806/personal-bests"
      expect(response.body).to eq("[]")
    end

    context "for an athlete with PRO subscription" do
      it "should be successful getting items for overview" do
        # arrange.
        url = "/#{API_ROOT_PATH}/athletes/9123806/personal-bests/overview"
        expected = "#{EXPECTED_FOLDER}/#{url}.json"

        # act.
        get url

        # assert.
        expect(response).to have_http_status(:success)
        FileHelpers.write_expected_file(expected, response.body)
        expect(response.body).to eq(File.read(expected))
      end

      it "should be successful getting recent items" do
        # arrange.
        url = "/#{API_ROOT_PATH}/athletes/9123806/personal-bests/recent"
        expected = "#{EXPECTED_FOLDER}/#{url}.json"

        # act.
        get url

        # assert.
        expect(response).to have_http_status(:success)
        FileHelpers.write_expected_file(expected, response.body)
        expect(response.body).to eq(File.read(expected))
      end

      distances = BestEffortType.all
      distances.each do |distance|
        it "should be successful getting best effort type '#{distance.name}'" do
          # arrange.
          url = "/#{API_ROOT_PATH}/athletes/9123806/personal-bests/#{distance.name.tr('/', '_')}"
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

    context "for an athlete without PRO subscription" do
      it "should be successful getting items for overview" do
        # arrange.
        url = "/#{API_ROOT_PATH}/athletes/111/personal-bests/overview"

        # act.
        get url

        # assert.
        expect(response).to have_http_status(:success)
      end

      it "should be successful getting recent items" do
        # arrange.
        url = "/#{API_ROOT_PATH}/athletes/111/personal-bests/recent"

        # act.
        get url

        # assert.
        expect(response).to have_http_status(:success)
      end

      it "should be 403 getting a non-major best effort type" do
        # arrange.
        url = "/#{API_ROOT_PATH}/athletes/111/personal-bests/1k"

        # act.
        get url

        # assert.
        expect(response).to have_http_status(403)
      end
    end
  end
end
