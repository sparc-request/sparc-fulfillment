require 'factory_girl'

namespace :data do

  desc 'Create fake data in CWF'
  task generate_data: :environment do

    # Globally unique :sparc_ids
    FactoryGirl.define { sequence(:sparc_id) }

    # Backdoor User for DEVELOPMENT env
    FactoryGirl.create(:user, email: 'email@musc.edu', password: 'password')

    # Create 10 Protocols
    FactoryGirl.create_list(:protocol_imported_from_sparc, 10)

    # Create 10 tasks
    FactoryGirl.create_list(:task, 10)
  end
end
