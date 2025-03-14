task add_inactive_services_to_exempt_list: :environment do
  setting = Sparc::Setting.find_by(key: "exempt_inactive_services")

  unless setting
    Rake::Task["add_exempt_inactive_services_setting"].invoke
    setting = Sparc::Setting.find_by(key: "exempt_inactive_services")
  end

  puts "Enter service ID(s) (comma separated):"
  input = STDIN.gets.chomp
  new_ids = input.split(",").map(&:strip).map(&:to_i).uniq

  current_ids = setting.value || []
  to_add = new_ids - current_ids

  if to_add.any?
    current_ids.concat(to_add)
    setting.update(value: current_ids.to_json)
  end

  puts "Updated exempt list: #{current_ids}"
end
