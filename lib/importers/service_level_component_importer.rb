class ServiceLevelComponentImporter

  def initialize(callback_url)
    @callback_url = callback_url
  end

  def update(sparc_id)
    if component = Component.find_by(sparc_id: sparc_id)
      component.update_attributes(normalized_component_attributes)
    end
  end

  private

  def normalized_component_attributes
    RemoteObjectNormalizer.new('Component', remote_service_level_component['service_level_component']).normalize!
  end

  def remote_service_level_component
    @remote_service_level_component ||= RemoteObjectFetcher.fetch(@callback_url)
  end
end
