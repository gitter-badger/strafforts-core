class Api::V1::MetaController < ApplicationController
  def index
    athlete = Athlete.find_by(id: params[:id])
    ApplicationController.raise_athlete_not_found_error(params[:id]) if athlete.nil?

    results = ApplicationController.get_meta(athlete.id)

    # Set user's last active time if it a logged in user.
    is_current_user = athlete.access_token == cookies.signed[:access_token]
    ApplicationController.set_last_active_at(athlete) if is_current_user

    render json: results
  end
end
