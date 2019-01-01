require "rails_helper"

RSpec.describe Api::V1::FaqCategoriesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "#{API_ROOT_PATH}/faq_categories").to route_to("#{API_ROOT_PATH}/faq_categories#index")
    end
  end
end
