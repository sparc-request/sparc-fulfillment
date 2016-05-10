namespace :data do
  desc "Delete unused services AND pricing maps"

  task destroy_unused_services: :environment do |t, args|
    ids = File.readlines(ENV["unused_services"])
    unused_services = Service.where(id: ids)

    bar = ProgressBar.new(unused_services.count)
    unused_services.map do |service|
      service.destroy
      service.pricing_maps.each(&:destroy)
      bar.increment!
    end
  end
end
