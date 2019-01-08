class Api::V1::BestEffortTypesController < ApplicationController
  # GET /best_effort_types
  def index
    @best_effort_types = BestEffortType.all_cached

    render json: @best_effort_types
  end
end
