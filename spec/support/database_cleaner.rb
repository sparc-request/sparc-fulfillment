RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner[:active_record, connection: :test].clean_with :truncation
    DatabaseCleaner[:active_record, connection: :test_sparc].clean_with :truncation
  end

  config.before(:each) do |example|
    DatabaseCleaner[:active_record, connection: :test].strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner[:active_record, connection: :test_sparc].strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
