require "rails_helper"

RSpec.describe State, type: :model do
  it { should validate_presence_of(:name) }

  it { should validate_uniqueness_of(:name).scoped_to(:country_id) }
  it { should_not validate_uniqueness_of(:name) }

  it { should belong_to(:country) }

  it { should have_many(:athlete_infos) }
end
