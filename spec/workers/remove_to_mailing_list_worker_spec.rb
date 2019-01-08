require "rails_helper"

RSpec.describe RemoveFromMailingListWorker, type: :worker do
  it "should enqueue the job" do
    RemoveFromMailingListWorker.perform_async(111, "tony.stark@avengers.com")
    expect(RemoveFromMailingListWorker).to have_enqueued_sidekiq_job(111, "tony.stark@avengers.com")
    expect(RemoveFromMailingListWorker).to save_backtrace
    expect(RemoveFromMailingListWorker).to be_retryable 0
  end
end
