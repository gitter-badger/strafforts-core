require "rails_helper"

RSpec.describe Gear, type: :model do
  it { should validate_presence_of(:athlete_id) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:gear_id) }

  it { should validate_uniqueness_of(:gear_id) }
  it { should_not validate_uniqueness_of(:name).scoped_to(:gear_id) }

  it { should belong_to(:athlete) }

  it { should have_many(:activities) }
end
