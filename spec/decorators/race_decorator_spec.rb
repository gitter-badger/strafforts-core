require "rails_helper"

RSpec.describe RaceDecorator, type: :decorator do
  it "should be the same entity after decorating" do
    # arrange.
    item = Race.find(1)

    # act.
    decorated_item = RaceDecorator.decorate(item).object

    # assert.
    expect(decorated_item).to eq(item)
  end
end
