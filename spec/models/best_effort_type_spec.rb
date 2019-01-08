require "rails_helper"

RSpec.describe BestEffortType, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  it { should have_many(:best_efforts) }

  describe ".find_by_name" do
    it "should get nil when the provided name matches nothing" do
      # act.
      item = BestEffortType.find_by_name("100 mile")

      # assert.
      expect(item).to be_nil
    end

    it "should get best effort type matching the provided name" do
      # act.
      item = BestEffortType.find_by_name("50k")

      # assert.
      expect(item.is_a?(BestEffortType)).to be true
      expect(item.name).to eq("50k")
    end
  end
end
