require "rails_helper"

RSpec.describe Api::V1::FaqsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "#{API_ROOT_PATH}/faqs").to route_to("#{API_ROOT_PATH}/faqs#index")
    end

    it "routes to #show" do
      expect(get: "#{API_ROOT_PATH}/faqs/1").to route_to("#{API_ROOT_PATH}/faqs#show", id: "1")
    end
  end
end
