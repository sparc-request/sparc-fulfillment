desc "Print API routes"
task api_routes: :environment do

  puts 'v1/CWFSPARC'

  CWFSPARC::API.routes.each do |route|
    puts route
  end
end