RSpec.configure do |config|

  config.before(:suite) do
    MODELS = ActiveRecord::Base.descendants.select { |model| model.respond_to?(:sparc_record?) }

    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner[:active_record, model: Service].clean_with(:truncation)
    DatabaseCleaner[:active_record, model: Service].strategy = :transaction
  end

  config.before(:each, type: :feature) do |example|
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    MODELS.
      each do |model|
        DatabaseCleaner[:active_record, model: model].start
        DatabaseCleaner[:active_record, model: Service].strategy = example.metadata[:js] ? :truncation : :transaction
      end
  end

  config.before(:each) do
    DatabaseCleaner.start
    MODELS.
      each do |model|
        DatabaseCleaner[:active_record, model: model].start
      end
  end

  config.after(:each) do
    DatabaseCleaner.clean
    MODELS.
      each do |model|
        DatabaseCleaner[:active_record, model: model].clean
      end
  end
end
