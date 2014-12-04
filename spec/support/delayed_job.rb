RSpec.configure do |config|

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
