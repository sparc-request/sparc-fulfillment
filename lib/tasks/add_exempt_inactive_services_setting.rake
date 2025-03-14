task add_exempt_inactive_services_setting: :environment do
  setting = Sparc::Setting.find_by(key: "exempt_inactive_services")

  unless setting
    Sparc::Setting.create(
      key: 'exempt_inactive_services',
      value: '[]',
      data_type: 'json',
      friendly_name: 'Exempt Inactive Services',
      description: 'List of service IDs that are inactive (is_available = false) but should still be viewable in the application'
      )
    puts "Setting created"
  else
    puts "Setting already exists"
  end
end
