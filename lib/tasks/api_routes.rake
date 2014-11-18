desc "Print API routes"
task api_routes: :environment do

  puts 'CWFSPARC::V1::APIv1'

  CWFSPARC::V1::APIv1.routes.each do |route|
    puts route
  end
end