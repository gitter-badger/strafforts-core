require "rails_helper"

RSpec.describe RenewSubscriptionsWorker, type: :worker do
  it "should enqueue the job" do
    RenewSubscriptionsWorker.perform_async
    expect(RenewSubscriptionsWorker).to have_enqueued_sidekiq_job
    expect(RenewSubscriptionsWorker).to save_backtrace
    expect(RenewSubscriptionsWorker).to be_retryable 0
  end
end
