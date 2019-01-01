require "rails_helper"

RSpec.describe BestEffort, type: :model do
  it { should validate_presence_of(:activity_id) }
  it { should validate_presence_of(:athlete_id) }
  it { should validate_presence_of(:best_effort_type_id) }
  it { should validate_presence_of(:distance) }
  it { should validate_presence_of(:moving_time) }
  it { should validate_presence_of(:elapsed_time) }

  it { should belong_to(:activity) }
  it { should belong_to(:athlete) }
  it { should belong_to(:best_effort_type) }
end
