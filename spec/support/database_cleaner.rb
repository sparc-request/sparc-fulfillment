RSpec.configure do |config|
  MODELS = ActiveRecord::Base.descendants.select { |model| model.respond_to?(:sparc_record?) }

  # Clean data before running the suite
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    MODELS.
      each do |model|
        DatabaseCleaner[:active_record, model: model].clean_with(:truncation)
      end
  end

  # Set default strategy to transaction
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    MODELS.
      each do |model|
        DatabaseCleaner[:active_record, model: model].strategy = :transaction
      end
  end

  # For js: true tests use the truncation strategy
  config.before(:each, js: true) do |example|
    DatabaseCleaner.strategy = :truncation
    MODELS.
      each do |model|
        DatabaseCleaner[:active_record, model: model].strategy = :truncation
      end
  end

  # For enqueue: false tests use the truncation strategy
  config.before(:each, enqueue: false) do |example|
    DatabaseCleaner.strategy = :truncation
    MODELS.
      each do |model|
        DatabaseCleaner[:active_record, model: model].strategy = :truncation
      end
  end

  # Start the cleaner to catch deletions in tests
  config.before(:each) do
    DatabaseCleaner.start
    MODELS.
      each do |model|
        DatabaseCleaner[:active_record, model: model].start
      end
  end

  # Clean data post-test
  config.append_after(:each) do
    DatabaseCleaner.clean
    MODELS.
      each do |model|
        DatabaseCleaner[:active_record, model: model].clean
      end
  end
end
