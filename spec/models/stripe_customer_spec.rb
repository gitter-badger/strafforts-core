require "rails_helper"

RSpec.describe StripeCustomer, type: :model do
  it { should validate_presence_of(:athlete_id) }
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:athlete_id) }

  it { should belong_to(:athlete) }
end
