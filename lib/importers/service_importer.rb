class ServiceImporter

  def initialize(callback_url)
    @callback_url = callback_url
  end

  def create
    Service.create(normalized_attributes)
  end

  def update(sparc_id)
    service = Service.find_by(sparc_id: sparc_id)

    service.update_attributes(normalized_attributes)
  end

  private

  def normalized_attributes
    remote_attributes   = RemoteObjectNormalizer.new('Service', remote_service['service']).normalize!
    attributes_to_merge = {
      sparc_core_id: remote_service['service']['process_ssrs_organization']['sparc_id'],
      sparc_core_name: remote_service['service']['process_ssrs_organization']['name']
    }

    remote_attributes.merge!(attributes_to_merge)
  end

  def remote_service
    @remote_service ||= RemoteObjectFetcher.fetch(@callback_url)
  end
end
