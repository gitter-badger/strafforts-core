require "rails_helper"

RSpec.describe Api::V1::BestEffortTypesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "#{API_ROOT_PATH}/best_effort_types").to route_to("#{API_ROOT_PATH}/best_effort_types#index")
    end
  end
end
