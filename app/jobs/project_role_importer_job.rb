class ProjectRoleImporterJob < ImporterJob

  def perform
    super {
      project_role_importer = ProjectRoleImporter.new(sparc_id, callback_url)

      case action
      when 'create'
        project_role_importer.create
      when 'update'
        project_role_importer.update
      when 'destroy'
        project_role_importer.destroy
      end
    }
  end
end
