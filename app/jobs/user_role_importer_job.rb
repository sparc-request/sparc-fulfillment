class UserRoleImporterJob < ImporterJob

  def perform
    super {
      identity_role_importer = UserRoleImporter.new(sparc_id, callback_url)

      case action
      when 'create'
        identity_role_importer.create
      when 'update'
        identity_role_importer.update
      when 'destroy'
        identity_role_importer.destroy
      end
    }
  end
end
