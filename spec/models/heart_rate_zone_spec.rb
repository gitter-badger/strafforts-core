require "rails_helper"

RSpec.describe HeartRateZones, type: :model do
  it { should validate_presence_of(:athlete_id) }
  it { should validate_presence_of(:zone_1_min) }
  it { should validate_presence_of(:zone_1_max) }
  it { should validate_presence_of(:zone_2_min) }
  it { should validate_presence_of(:zone_2_max) }
  it { should validate_presence_of(:zone_3_min) }
  it { should validate_presence_of(:zone_3_max) }
  it { should validate_presence_of(:zone_4_min) }
  it { should validate_presence_of(:zone_4_max) }
  it { should validate_presence_of(:zone_5_min) }
  it { should validate_presence_of(:zone_5_max) }

  it { should validate_uniqueness_of(:athlete_id) }

  it { should belong_to(:athlete) }
end
