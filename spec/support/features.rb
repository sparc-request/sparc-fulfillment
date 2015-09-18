Dir[Rails.root.join("spec/support/features/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include Features::BootstrapHelpers, type: :feature
  config.include Features::BootstrapTableHelpers, type: :feature
  config.include Features::BrowserHelpers, type: :feature
  config.include Features::TaskHelpers, type: :feature
  config.include Features::VisitHelpers, type: :feature
end
