RSpec.configure do |config|

  config.before(:suite) do
    Dir.mkdir(ENV.fetch('DOCUMENT_ROOT')) unless Dir.exists?(ENV.fetch('DOCUMENT_ROOT'))
  end

  config.after(:suite) do

    Dir.entries(ENV.fetch('DOCUMENT_ROOT')).each do |file|
      unless File.directory?(file)
        File.delete File.join(ENV.fetch('DOCUMENT_ROOT'), file)
      end
    end
  end
end
