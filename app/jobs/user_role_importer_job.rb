class UserRoleImporterJob < ImporterJob

  def perform
    super {
      user_role_importer = UserRoleImporter.new(sparc_id, callback_url)

      case action
      when 'create'
        user_role_importer.create
      when 'update'
        user_role_importer.update
      when 'destroy'
        user_role_importer.destroy
      end
    }
  end
end
