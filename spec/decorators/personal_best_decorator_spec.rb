require "rails_helper"

RSpec.describe PersonalBestDecorator, type: :decorator do
  it "should be the same entity after decorating" do
    # arrange.
    item = BestEffort.find(1587424799)

    # act.
    decorated_item = PersonalBestDecorator.decorate(item).object

    # assert.
    expect(decorated_item).to eq(item)
  end
end
