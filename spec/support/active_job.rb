RSpec.configure do |config|

  config.include(RSpec::ActiveJob)

  config.before(:each, enqueue: false) do
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
  end

  config.after(:each) do
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
    ActiveJob::Base.queue_adapter.enqueued_jobs = []
    ActiveJob::Base.queue_adapter.performed_jobs = []
  end
end
