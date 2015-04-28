class ServiceImporter

  def initialize(callback_url)
    @callback_url = callback_url
  end

  def create
    create_service
    create_service_level_components
  end

  def update(sparc_id)
    if service = Service.find_by(sparc_id: sparc_id)
      service.update_attributes(normalized_service_attributes)
    else
      create_service
    end
  end

  private

  def create_service
    @service = Service.create(normalized_service_attributes)
  end

  def create_service_level_components
    if remote_service["service"]["service_level_components_count"] > 0

      remote_service_level_components["service_level_components"].each do |remote_service_level_component|
        local_component_attributes = RemoteObjectNormalizer.new("Component", remote_service_level_component).normalize!

        @service.components.push Component.new(local_component_attributes)
      end
    end
  end

  def normalized_service_attributes
    remote_service_attributes     = RemoteObjectNormalizer.new('Service', remote_service['service']).normalize!
    servivce_attributes_to_merge  = {
      sparc_core_id: remote_service['service']['process_ssrs_organization']['sparc_id'],
      sparc_core_name: remote_service['service']['process_ssrs_organization']['name']
    }

    remote_service_attributes.merge!(servivce_attributes_to_merge)
  end

  def remote_service
    @remote_service ||= RemoteObjectFetcher.fetch(callback_url_with_depth)
  end

  def remote_service_level_components
    @remote_service_level_components ||= RemoteObjectFetcher.new('service_level_component', remote_service_level_component_ids, { depth: 'full' }).build_and_fetch
  end

  def remote_service_level_component_ids
    remote_service["service"]["service_level_components"].
      map { |service_level_component| service_level_component["sparc_id"] }.
      compact
  end

  def callback_url_with_depth
    @callback_url_with_depth ||= [@callback_url, "?depth=full_with_shallow_reflections"].join
  end
end
