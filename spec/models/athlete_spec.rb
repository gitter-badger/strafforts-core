require "rails_helper"

RSpec.describe Athlete, type: :model do
  it { should validate_presence_of(:access_token) }

  it { should have_one(:athlete_info) }

  it { should have_many(:activities) }
  it { should have_many(:best_efforts) }
  it { should have_many(:gears) }
  it { should have_many(:heart_rate_zones) }
  it { should have_many(:races) }
  it { should have_many(:subscriptions) }
end
