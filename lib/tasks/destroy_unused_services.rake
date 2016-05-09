namespace :data do
  desc "Delete unused services AND pricing maps"

  task destroy_unused_services: :environment do
    TABLES_WITH_SERVICE_FOREIGN_KEY = [Fulfillment, Procedure,
      Sparc::Procedure, LineItem, Sparc::LineItem, Sparc::Charge,
      Sparc::ServiceProvider, Sparc::ServiceRelation]

    used_services = TABLES_WITH_SERVICE_FOREIGN_KEY.map do |table|
      table.where.not(service_id: nil).distinct.pluck(:service_id)
    end.reduce(&:|)

    # Get services not associated with CWF LineItems, not a custom added service
    unused_services = Service.includes(organization: :parent).
      where.not(id: used_services).
      distinct

    bar = ProgressBar.new(unused_services.count)
    unused_services.map do |service|
      service.destroy
      service.pricing_maps.each(&:destroy)
      bar.increment!
    end
  end
end
