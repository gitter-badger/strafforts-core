class Api::V1::BestEffortsController < ApplicationController
  def index
    retrieve_best_efforts(false)
  end

  def top_one_by_year
    retrieve_best_efforts(true)
  end

  private

  def retrieve_best_efforts(top_one_by_year_only)
    athlete = Athlete.find_by(id: params[:id])
    ApplicationController.raise_athlete_not_found_error(params[:id]) if athlete.nil?

    heart_rate_zones = ApplicationHelper::Helper.get_heart_rate_zones(athlete.id)

    results = []
    unless params[:distance].blank?
      # '1/2 mile' is passed in as 1_2-mile, 'Half Marathon' is passed in as half-marathon
      # as defined in createView method in app/assets/javascripts/athletes/views/navigationSidebar.ts.
      distance = params[:distance].tr("_", "/").tr("-", " ")
      best_effort_type = BestEffortType.find_by_name(distance)
      if best_effort_type.nil?
        Rails.logger.warn("Could not find requested best effort type '#{distance}' for athlete '#{athlete.id}'.")
        render json: { error: Messages::DISTANCE_NOT_FOUND }.to_json, status: 404
        return
      end

      items = if top_one_by_year_only
                BestEffort.find_top_one_of_each_year(athlete.id, best_effort_type.id)
              else
                BestEffort.find_top_by_athlete_id_and_best_effort_type_id(
                  athlete.id, best_effort_type.id, BEST_EFFORTS_LIMIT
                )
              end
      results = ApplicationHelper::Helper.shape_best_efforts(
        items, heart_rate_zones, athlete.athlete_info.measurement_preference
      )
    end

    render json: results
  end
end
