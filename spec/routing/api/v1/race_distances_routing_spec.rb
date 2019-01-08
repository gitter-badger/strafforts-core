require "rails_helper"

RSpec.describe Api::V1::RaceDistancesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "#{API_ROOT_PATH}/race_distances").to route_to("#{API_ROOT_PATH}/race_distances#index")
    end
  end
end
