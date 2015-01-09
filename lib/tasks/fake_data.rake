require 'factory_girl'

namespace :data do

  desc 'Create fake data in CWF'
  task generate_data: :environment do

    FactoryGirl.define { sequence(:sparc_id) }
    FactoryGirl.create_list(:protocol_imported_from_sparc, 10)
  end
end
