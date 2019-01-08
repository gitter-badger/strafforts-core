require "rails_helper"

RSpec.describe Api::V1::FaqsController, type: :request do
  let(:expected_folder) { "./spec/requests/expected".freeze }

  it "GET FAQs should be successful" do
    # arrange.
    url = "/#{API_ROOT_PATH}/faqs"

    # act.
    get url

    # assert.
    expect(response).to have_http_status(:success)
  end

  it "GET FAQs by ID should be successful" do
    # arrange.
    url = "/#{API_ROOT_PATH}/faqs/1"

    # act.
    get url

    # assert.
    expect(response).to have_http_status(:success)
  end
end
