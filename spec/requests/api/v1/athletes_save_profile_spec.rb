require "rails_helper"

RSpec.describe Api::V1::AthletesController, type: :request do
  describe "POST save-profile" do
    let(:athlete_id) { "98765" }
    let(:url) { "/#{API_ROOT_PATH}/athletes/#{athlete_id}/save-profile" }

    it "should return 404 when the requested athlete does not exist" do
      post url
      expect(response).to have_http_status(404)
    end

    it "should return 403 when requested athlete is not the current user" do
      # arrange.
      FactoryBot.build(:athlete, id: athlete_id)

      # act.
      post url

      # assert.
      expect(response).to have_http_status(403)
    end

    context "should set is_public to true" do
      let(:athlete) { FactoryBot.build(:athlete, id: athlete_id) }

      it "when POST without parameters" do
        # arrange.
        setup_cookie(athlete.access_token)

        expect(athlete).not_to be_nil
        expect(athlete.is_public).to be false

        # act.
        post url

        # assert.
        athlete.reload
        expect(athlete.is_public).to be true
      end

      it "when POST with is_public = true" do
        # arrange.
        setup_cookie(athlete.access_token)

        expect(athlete).not_to be_nil
        expect(athlete.is_public).to be false

        # act.
        post url, params: { is_public: true }

        # assert.
        athlete.reload
        expect(athlete.is_public).to be true
      end
    end

    context "should set is_public to false" do
      let(:athlete) { FactoryBot.build(:athlete_with_public_profile, id: athlete_id) }

      it "when POST with is_public = false" do
        # arrange.
        setup_cookie(athlete.access_token)

        expect(athlete).not_to be_nil
        expect(athlete.is_public).to be true

        # act.
        post url, params: { is_public: false }

        # assert.
        athlete.reload
        expect(athlete.is_public).to be false
      end
    end
  end
end
