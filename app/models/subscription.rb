class Subscription < ApplicationRecord
  validates :athlete_id, :subscription_plan_id, :starts_at, presence: true

  validates :is_deleted, :is_active, :cancel_at_period_end, inclusion: { in: [true, false] }

  belongs_to :athlete, foreign_key: "athlete_id"
  belongs_to :subscription_plan, foreign_key: "subscription_plan_id"
end
