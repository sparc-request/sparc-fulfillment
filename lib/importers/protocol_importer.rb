class ProtocolImporter

  def initialize(callback_url)
    @callback_url = callback_url
  end

  def create
    disable_auditing
    import_arms_and_their_decendents
    import_one_time_fee_line_items
    enable_auditing
    update_faye(local_protocol)
  end

  private

  def normalized_attributes
    @normalized_attributes ||= RemoteObjectNormalizer.new('Protocol', remote_protocol['protocol']).normalize!
  end

  def attributes_to_merge
    {
      sparc_id:               remote_protocol['protocol']['sparc_id'],
      study_cost:             remote_sub_service_request['sub_service_request']['grand_total'],
      stored_percent_subsidy: remote_sub_service_request['sub_service_request']['stored_percent_subsidy'],
      status:                 remote_sub_service_request['sub_service_request']['status'],
      sub_service_request_id: remote_sub_service_request['sub_service_request']['sparc_id']
    }
  end

  def disable_auditing
    PaperTrail.enabled = false
  end

  def enable_auditing
    PaperTrail.enabled = true
  end

  def import_arms_and_their_decendents
    ArmImporter.new(local_protocol, remote_protocol, remote_sub_service_request).create
  end

  def import_one_time_fee_line_items
    LineItemImporter.new(nil, local_protocol, remote_sub_service_request['sub_service_request']).create
  end

  def local_protocol
    @local_protocol ||= Protocol.create(normalized_attributes.merge!(attributes_to_merge))
  end

  def remote_protocol
    protocol_id = remote_service_request['service_request']['protocol_id']

    @remote_protocol ||= RemoteObjectFetcher.new('protocol', protocol_id, { depth: 'full_with_shallow_reflections' }).build_and_fetch
  end

  def remote_sub_service_request
    remote_sub_service_request  ||= RemoteObjectFetcher.fetch(@callback_url)
    @remote_sub_service_request ||= RemoteObjectFetcher.new('sub_service_request', remote_sub_service_request['sub_service_request']['sparc_id'], { depth: 'full_with_shallow_reflections' }).build_and_fetch
  end

  def remote_service_request
    service_request_id = remote_sub_service_request['sub_service_request']['service_request_id']

    @remote_service_request ||= RemoteObjectFetcher.new('service_request', service_request_id, { depth: 'full' }).build_and_fetch
  end

  def update_faye(object)
    FayeJob.enqueue(object)
  end
end
