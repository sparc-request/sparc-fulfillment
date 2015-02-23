class ProjectRoleImporterJob < ImporterJob

  def perform
    super {
      case action
      when 'create'
        create_project_role
      when 'update'
        update_project_role
      when 'destroy'
        destroy_project_role
      end
    }
  end

  private

  def create_project_role
    user = find_or_create_user

    UserRole.create(user: user,
                    protocol: local_protocol,
                    rights: remote_project_role['project_role']['project_rights'],
                    role: remote_project_role['project_role']['role'],
                    role_other: remote_project_role['project_role']['role_other'])
  end

  def update_project_role
    local_user_role.update_attributes(rights: remote_project_role['project_role']['project_rights'],
                                      role: remote_project_role['project_role']['role'],
                                      role_other: remote_project_role['project_role']['role_other'])
  end

  def destroy_project_role
    local_user_role.destroy
  end

  def find_or_create_user
    unless user = User.find_by_email(remote_identity['identity']['email'])
      user = User.create( first_name: remote_identity['identity']['first_name'],
                          last_name: remote_identity['identity']['last_name'],
                          email: remote_identity['identity']['email'],
                          password: '1234567890')
      # TODO: Implement a method of creating a User without a password
    end

    user
  end

  def remote_project_role
    @remote_project_role ||= RemoteObjectFetcher.fetch(callback_url)
  end

  def remote_identity
    remote_identity_id = remote_project_role['project_role']['identity_id']

    @remote_identity ||= RemoteObjectFetcher.new('identity', remote_identity_id, { depth: 'full' }).build_and_fetch
  end

  def local_user_role
    @local_user_role ||= UserRole.where(protocol: local_protocol, user: local_user).first
  end

  def local_protocol
    @local_protocol ||= Protocol.find_by_sparc_id(remote_project_role['project_role']['protocol_id'])
  end

  def local_user
    @local_user ||= User.find_by_email(remote_identity['identity']['email'])
  end
end
