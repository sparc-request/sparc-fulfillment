class ProtocolImporter

  def initialize(callback_url)
    @callback_url = callback_url
  end

  def create
    normalized_attributes = RemoteObjectNormalizer.new('Protocol', remote_protocol['protocol']).normalize!
    attributes_to_merge   = {
      sparc_id: remote_protocol['protocol']['sparc_id'],
      study_cost: remote_sub_service_request['sub_service_request']['grand_total'],
      stored_percent_subsidy: remote_sub_service_request['sub_service_request']['stored_percent_subsidy'],
      status: remote_sub_service_request['sub_service_request']['status']
    }
    @local_protocol = Protocol.create(normalized_attributes.merge!(attributes_to_merge))

    import_user_roles
    import_arms_and_their_decendents

    update_faye(@local_protocol)
  end

  # def update
  # end

  # def destroy
  # end

  private

  def import_user_roles
    if remote_user_roles.present?
      remote_user_roles.each do |user_role|
        UserRoleImporter.new(user_role['sparc_id'], user_role['callback_url']).create
      end
    end
  end

  def import_arms_and_their_decendents
    ArmImporter.new(@local_protocol, remote_protocol, remote_service_request).create
  end

  def remote_protocol
    protocol_id = remote_service_request['service_request']['protocol_id']

    @remote_protocol ||= RemoteObjectFetcher.new('protocol', protocol_id, { depth: 'full_with_shallow_reflections' }).build_and_fetch
  end

  def remote_sub_service_request
    @remote_sub_service_request ||= RemoteObjectFetcher.fetch(@callback_url)
  end

  def remote_service_request
    service_request_id = remote_sub_service_request['sub_service_request']['service_request_id']

    @remote_service_request ||= RemoteObjectFetcher.new('service_request', service_request_id, { depth: 'full' }).build_and_fetch
  end

  def remote_user_roles
    remote_protocol['protocol']['project_roles']
  end

  def update_faye(object)
    FayeJob.enqueue(object)
  end
end
