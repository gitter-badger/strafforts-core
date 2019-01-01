class Api::V1::RaceDistancesController < ApplicationController
  # GET /race_distances
  def index
    @race_distances = RaceDistance.all_cached

    render json: @race_distances
  end
end
