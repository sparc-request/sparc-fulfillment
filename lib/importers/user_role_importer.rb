class UserRoleImporter

  def initialize(sparc_id, callback_url)
    @sparc_id     = sparc_id
    @callback_url = callback_url
  end

  def create
    user = find_or_create_user

    IdentityRole.create(identity: user,
                    protocol: local_protocol,
                    rights: remote_project_role['project_role']['project_rights'],
                    role: remote_project_role['project_role']['role'],
                    role_other: remote_project_role['project_role']['role_other'])
  end

  def update
    local_identity_role.update_attributes(rights: remote_project_role['project_role']['project_rights'],
                                      role: remote_project_role['project_role']['role'],
                                      role_other: remote_project_role['project_role']['role_other'])
  end

  def destroy
    local_identity_role.destroy
  end

  private

  def find_or_create_user
    unless user = Identity.find_by_email(remote_identity['identity']['email'])
      user = Identity.create( first_name: remote_identity['identity']['first_name'],
                          last_name: remote_identity['identity']['last_name'],
                          email: remote_identity['identity']['email'],
                          password: '1234567890')
      # TODO: Implement a method of creating a Identity without a password
    end

    user
  end

  def remote_project_role
    @remote_project_role ||= RemoteObjectFetcher.fetch(@callback_url)
  end

  def remote_identity
    remote_identity_id = remote_project_role['project_role']['identity_id']

    @remote_identity ||= RemoteObjectFetcher.new('identity', remote_identity_id, { depth: 'full' }).build_and_fetch
  end

  def local_identity_role
    @local_identity_role ||= IdentityRole.where(protocol: local_protocol, identity: local_user).first
  end

  def local_protocol
    @local_protocol ||= Protocol.find_by_sparc_id(remote_project_role['project_role']['protocol_id'])
  end

  def local_user
    @local_user ||= Identity.find_by_email(remote_identity['identity']['email'])
  end
end
