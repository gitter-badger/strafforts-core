require "rails_helper"

RSpec.describe Api::V1::SubscriptionPlansController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "#{API_ROOT_PATH}/subscription_plans").to route_to("#{API_ROOT_PATH}/subscription_plans#index")
    end
  end
end
