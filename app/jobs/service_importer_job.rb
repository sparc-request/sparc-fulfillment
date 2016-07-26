class ServiceImporterJob < ImporterJob

  def perform sparc_id, callback_url, action
    super {
      case action
      when 'create'
        #create
      when 'update'
        update_components(callback_url)
      when 'destroy'
        #destroy
      end
    }
  end

  private

  def update_components(callback_url)
    service = RemoteObjectFetcher.fetch(callback_url)["service"]
    if service["one_time_fee"]
      service_components = service["components"].split(',')
      line_items = LineItem.where(service_id: service["sparc_id"])
      line_items.each do |li|
        li_components = li.components.map(&:component)
        to_destroy = li_components - service_components
        to_destroy.each{ |td| li.components.where(component: td).first.destroy }

        to_add = service_components - li_components
        to_add.each{ |ta| Component.create(component: ta, position: service_components.index(ta), composable_type: "LineItem", composable_id: li.id) }
      end
    end
  end
end
