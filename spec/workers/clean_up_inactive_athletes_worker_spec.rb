require "rails_helper"

RSpec.describe CleanUpInactiveAthletesWorker, type: :worker do
  it "should enqueue the job" do
    CleanUpInactiveAthletesWorker.perform_async
    expect(CleanUpInactiveAthletesWorker).to have_enqueued_sidekiq_job
    expect(CleanUpInactiveAthletesWorker).to save_backtrace
    expect(CleanUpInactiveAthletesWorker).to be_retryable 0
  end
end
