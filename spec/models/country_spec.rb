require "rails_helper"

RSpec.describe Country, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  it { should have_many(:athlete_infos) }
  it { should have_many(:cities) }
  it { should have_many(:states) }
end
