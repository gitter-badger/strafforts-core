require "rails_helper"

RSpec.describe Activity, type: :model do
  it { should validate_presence_of(:athlete_id) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:distance) }
  it { should validate_presence_of(:moving_time) }
  it { should validate_presence_of(:elapsed_time) }
  it { should validate_presence_of(:start_date) }
  it { should validate_presence_of(:start_date_local) }
  it { should validate_presence_of(:workout_type_id) }

  it { should belong_to(:athlete) }
  it { should belong_to(:workout_type) }

  it { should have_many(:best_efforts) }
end
