class ProjectRoleImporter

  def initialize(sparc_id, callback_url)
    @sparc_id     = sparc_id
    @callback_url = callback_url
  end

  def create
    ProjectRole.create(identity: local_identity,
                        protocol: local_protocol,
                        rights: remote_project_role['project_role']['project_rights'],
                        role: remote_project_role['project_role']['role'],
                        role_other: remote_project_role['project_role']['role_other'])
  end

  def update
    local_project_role.update_attributes(rights: remote_project_role['project_role']['project_rights'],
                                          role: remote_project_role['project_role']['role'],
                                          role_other: remote_project_role['project_role']['role_other'])
  end

  def destroy
    local_project_role.destroy
  end

  private

  def remote_project_role
    @remote_project_role ||= RemoteObjectFetcher.fetch(@callback_url)
  end

  def local_project_role
    @local_project_role ||= ProjectRole.where(protocol: local_protocol, identity: local_identity).first
  end

  def local_protocol
    @local_protocol ||= Protocol.find_by(sparc_id: remote_project_role['project_role']['protocol_id'])
  end

  def local_identity
    @local_identity ||= Identity.find(remote_project_role['project_role']['identity_id'])
  end
end
