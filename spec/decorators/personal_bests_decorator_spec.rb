require "json"
require "rails_helper"

RSpec.describe PersonalBestsDecorator, type: :decorator do
  let(:expected_folder) { "./spec/requests/expected".freeze }

  let(:items) { BestEffort.find_all_pbs_by_athlete_id(9123806) }

  it "should get the same amount of items after decorating" do
    # act.
    decorated_items = PersonalBestsDecorator.decorate(items).object

    # assert.
    expect(decorated_items.count).to be > 0
    expect(decorated_items.count).to eq(items.count)
  end

  describe ".to_show_in_overview" do
    let(:expected) { "#{expected_folder}/best_efforts.to_show_in_overview.json" }

    it "should match expected" do
      skip "ApplicationHelper.find_activities_by_distance does not work properly for RSpec for some reason"

      # act.
      decorator = PersonalBestsDecorator.decorate(items)

      # assert.
      expect(decorator.to_show_in_overview.to_json).to eq(File.read(expected))
    end
  end
end
