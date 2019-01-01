require "rails_helper"

RSpec.describe Faq, type: :model do
  it { should validate_presence_of(:faq_category_id) }

  it { should belong_to(:faq_category) }
end
