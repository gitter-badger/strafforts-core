class Api::V1::WorkoutTypesController < ApplicationController
  # GET /workout_types
  def index
    @workout_types = WorkoutType.all_cached

    render json: @workout_types
  end
end
