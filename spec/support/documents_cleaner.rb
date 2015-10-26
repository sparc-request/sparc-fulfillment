RSpec.configure do |config|

  config.before(:suite) do
    Dir.mkdir(ENV.fetch('DOCUMENTS_FOLDER')) unless Dir.exists?(ENV.fetch('DOCUMENTS_FOLDER'))
  end

  config.after(:suite) do

    Dir.entries(ENV.fetch('DOCUMENTS_FOLDER')).each do |file|
      unless File.directory?(file)
        File.delete File.join(ENV.fetch('DOCUMENTS_FOLDER'), file)
      end
    end
  end
end
