class Api::V1::MetaController < ApplicationController
  before_action :find_athlete

  def index
    results = ApplicationController.get_meta(@athlete.id)

    # Set user's last active time if it a logged in user.
    is_current_user = @athlete.access_token == cookies.signed[:access_token]
    if is_current_user
      @athlete.last_active_at = Time.now.utc
      @athlete.save!
    end

    render json: results
  end
end
