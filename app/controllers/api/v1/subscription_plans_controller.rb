class Api::V1::SubscriptionPlansController < ApplicationController
  # GET /subscription_plans
  def index
    @subscription_plans = SubscriptionPlan.all_cached

    render json: @subscription_plans
  end
end
