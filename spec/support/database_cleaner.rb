RSpec.configure do |config|
  Rails.application.eager_load!
  MODELS = ActiveRecord::Base.descendants.select { |model| model.respond_to?(:sparc_record?) }

  config.before(:suite) do

    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
    MODELS.
      each do |model|
        DatabaseCleaner[:active_record, model: model].clean_with(:truncation)
        DatabaseCleaner[:active_record, model: model].strategy = :transaction
      end
  end

  config.before(:each, type: :feature) do |example|
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    MODELS.
      each do |model|
        DatabaseCleaner[:active_record, model: model].start
        DatabaseCleaner[:active_record, model: model].strategy = example.metadata[:js] ? :truncation : :transaction
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
