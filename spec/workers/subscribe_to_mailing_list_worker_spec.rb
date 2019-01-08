require "rails_helper"

RSpec.describe SubscribeToMailingListWorker, type: :worker do
  it "should enqueue the job" do
    SubscribeToMailingListWorker.perform_async(111)
    expect(SubscribeToMailingListWorker).to have_enqueued_sidekiq_job(111)
    expect(SubscribeToMailingListWorker).to save_backtrace
  end
end
