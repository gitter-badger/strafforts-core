require "rails_helper"

RSpec.describe Subscription, type: :model do
  it { should validate_presence_of(:athlete_id) }
  it { should validate_presence_of(:subscription_plan_id) }
  it { should validate_presence_of(:starts_at) }

  it { should belong_to(:athlete) }
  it { should belong_to(:subscription_plan) }
end
