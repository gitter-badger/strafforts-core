require "rails_helper"

RSpec.describe RaceDistance, type: :model do
  it { should validate_presence_of(:distance) }
  it { should validate_uniqueness_of(:distance) }

  it { should have_many(:races) }
end
