class ServiceLevelComponentImporter

  def initialize(callback_url)
    @callback_url = callback_url
  end

  def create
    destroy_all_components
    create_new_components_from_remote
  end

  alias :update :create
  alias :destroy :create

  private

  def destroy_all_components
    local_service.components.destroy_all
  end

  def create_new_components_from_remote
    if remote_service_has_service_level_components?

      remote_service_level_components["service_level_components"].each do |remote_service_level_component|
        component = Component.new(normalized_component_attributes(remote_service_level_component))

        local_service.components.push component
      end
    end
  end

  def normalized_component_attributes(remote_service_level_component)
    RemoteObjectNormalizer.new('Component', remote_service_level_component).normalize!
  end

  def remote_service_level_component
    callback_url_with_depth = @callback_url.gsub("full", "full_with_shallow_reflections")

    @remote_service_level_component ||= RemoteObjectFetcher.fetch(callback_url_with_depth)
  end

  def remote_service_level_components
    remote_service_level_component_ids = remote_service["service"]["service_level_components"].map { |service_level_component| service_level_component["sparc_id"] }

    @remote_service_level_components ||= RemoteObjectFetcher.new('service_level_component', remote_service_level_component_ids, { depth: 'full' }).build_and_fetch
  end

  def remote_service
    remote_service_sparc_id = remote_service_level_component["service_level_component"]["service"]["sparc_id"]

    @remote_service ||= RemoteObjectFetcher.new('service', remote_service_sparc_id, { depth: 'full_with_shallow_reflections' }).build_and_fetch
  end

  def remote_service_has_service_level_components?
    remote_service["service"]["service_level_components_count"] > 0
  end

  def local_service
    sparc_id = remote_service["service"]["sparc_id"]

    @local_service ||= Service.find_by(sparc_id: sparc_id)
  end
end
