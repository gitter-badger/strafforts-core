require "rails_helper"

RSpec.describe FetchActivityWorker, type: :worker do
  it "should enqueue the job" do
    FetchActivityWorker.perform_async(ACCESS_TOKEN)
    expect(FetchActivityWorker).to have_enqueued_sidekiq_job(ACCESS_TOKEN)
    expect(FetchActivityWorker).to be_retryable 0
  end
end
