module DelayedJobHelpers

  def work_off
    Delayed::Worker.new.work_off
  end

  def destroy_all_delayed_jobs
    Delayed::Job.destroy_all
  end
end

RSpec.configure do |config|

  config.after(:each) do
    Delayed::Job.destroy_all
  end

  config.before(:each, delay: true) do
    Delayed::Worker.delay_jobs = true
  end

  config.after(:each, delay: true) do
    Delayed::Worker.delay_jobs = false
  end

  config.before(:each, delay: false) do
    Delayed::Worker.delay_jobs = false
  end
end
