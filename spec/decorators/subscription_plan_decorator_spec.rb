require "rails_helper"

RSpec.describe SubscriptionPlanDecorator, type: :decorator do
  let(:plan) { SubscriptionPlan.find_by(name: "90-day PRO") }

  it "should be the same entity after decorating" do
    # act.
    decorated_plan = SubscriptionPlanDecorator.decorate(plan)

    # assert.
    expect(decorated_plan).to eq(plan)
  end

  describe ".amount" do
    it "should be the correct amount" do
      # act.
      decorated_plan = SubscriptionPlanDecorator.decorate(plan)

      # assert.
      expect(decorated_plan.amount).to eq(2.99)
    end

    it "should be 0 when subscription plan cannot be found" do
      # arrange.
      plan = SubscriptionPlan.find_by(name: "90000-day PRO Plan")

      # act.
      decorated_plan = SubscriptionPlanDecorator.decorate(plan)

      # assert.
      expect(decorated_plan.amount).to eq(0)
    end

    it "should be 0 when subscription plan has amount of 0" do
      # arrange.
      plan = SubscriptionPlan.find_by(name: "Lifetime PRO Plan")

      # act.
      decorated_plan = SubscriptionPlanDecorator.decorate(plan)

      # assert.
      expect(decorated_plan.amount).to eq(0)
    end
  end

  describe ".amount_per_month" do
    it "should be the correct amount" do
      # act.
      decorated_plan = SubscriptionPlanDecorator.decorate(plan)

      # assert.
      expect(decorated_plan.amount_per_month).to eq(0.99)
    end

    it "should be 0 when subscription plan cannot be found" do
      # arrange.
      plan = SubscriptionPlan.find_by(name: "90000-day PRO Plan")

      # act.
      decorated_plan = SubscriptionPlanDecorator.decorate(plan)

      # assert.
      expect(decorated_plan.amount_per_month).to eq(0)
    end

    it "should be 0 when subscription plan has amount of 0" do
      # arrange.
      plan = SubscriptionPlan.find_by(name: "Lifetime PRO Plan")

      # act.
      decorated_plan = SubscriptionPlanDecorator.decorate(plan)

      # assert.
      expect(decorated_plan.amount_per_month).to eq(0)
    end
  end
end
