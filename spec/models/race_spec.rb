require "rails_helper"

RSpec.describe Race, type: :model do
  it { should validate_presence_of(:activity_id) }
  it { should validate_presence_of(:athlete_id) }
  it { should validate_presence_of(:race_distance_id) }

  it { should belong_to(:activity) }
  it { should belong_to(:athlete) }
  it { should belong_to(:race_distance) }
end
