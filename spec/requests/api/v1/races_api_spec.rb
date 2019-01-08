require "rails_helper"

RSpec.describe Api::V1::RacesController, type: :request do
  let(:athlete_id) { "98765" }
  let(:url) { "/#{API_ROOT_PATH}/athletes/#{athlete_id}/races" }

  describe "GET index" do
    it "should be 404 when the requested athlete does not exist" do
      # act.
      get url

      # assert.
      expect(response).to have_http_status(404)
    end

    context "for an athlete without PRO subscription" do
      before(:each) do
        FactoryBot.build(:athlete, id: athlete_id)
      end

      it "should be a 404 with an invalid distance" do
        # act.
        get "#{url}/100m"

        # assert.
        expect(response).to have_http_status(404)
      end

      it "should be a 404 with an invalid year prior to 2000" do
        # act.
        get "#{url}/1999"

        # assert.
        expect(response).to have_http_status(404)
      end

      it "should be empty when distance or year is not specified" do
        # act.
        get url

        # assert.
        expect(response.body).to eq("[]")
      end
    end

    context "for an athlete without PRO subscription" do
      before(:each) do
        FactoryBot.build(:athlete, id: athlete_id)
      end

      it "should get 403 when getting race distance '20k' for an athlete without a PRO plan" do
        # act.
        get "#{url}/20k"

        # assert.
        expect(response).to have_http_status(403)
      end

      it "should get 403 when getting race year '2014' for an athlete without a PRO plan" do
        # act.
        get "#{url}/2014"

        # assert.
        expect(response).to have_http_status(403)
      end
    end

    context "for an athlete with PRO subscription" do
      it "should get a 404 with an invalid year latter than 2000" do
        # arrange.
        url = "/#{API_ROOT_PATH}/athletes/9123806/races/2002"

        # act.
        get url

        # assert.
        expect(response).to have_http_status(404)
      end

      it "should be successful getting items for overview" do
        # arrange.
        url = "/#{API_ROOT_PATH}/athletes/9123806/races/overview"
        expected = "#{EXPECTED_FOLDER}#{url}.json"

        # act.
        get url

        # assert.
        expect(response).to have_http_status(:success)
        FileHelpers.write_expected_file(expected, response.body)
        expect(response.body).to eq(File.read(expected))
      end

      it "should be successful getting recent items" do
        # arrange.
        url = "/#{API_ROOT_PATH}/athletes/9123806/races/recent"
        expected = "#{EXPECTED_FOLDER}#{url}.json"

        # act.
        get url

        # assert.
        expect(response).to have_http_status(:success)
        FileHelpers.write_expected_file(expected, response.body)
        expect(response.body).to eq(File.read(expected))
      end

      distances = RaceDistance.all
      distances.each do |distance|
        it "should be successful getting race distance '#{distance.name}'" do
          # arrange.
          url = "/#{API_ROOT_PATH}/athletes/9123806/races/#{distance.name}"
          expected = "#{EXPECTED_FOLDER}#{url}.json"

          # act.
          get URI.encode(url)

          # assert.
          expect(response).to have_http_status(:success)
          FileHelpers.write_expected_file(expected, response.body)
          expect(response.body).to eq(File.read(expected))
        end
      end

      VALID_YEARS = %w[2014 2015 2016].freeze
      VALID_YEARS.each do |year|
        it "should be successful getting race year '#{year}'" do
          # arrange.
          url = "/#{API_ROOT_PATH}/athletes/9123806/races/#{year}"
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
end
