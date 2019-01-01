require "rails_helper"

RSpec.describe AthleteInfo, type: :model do
  it { should belong_to(:athlete) }
  it { should belong_to(:city).optional }
  it { should belong_to(:state).optional }
  it { should belong_to(:country).optional }
end
