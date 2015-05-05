class ServiceLevelComponentImporterJob < ImporterJob

  def perform
    super {
      case action
      when 'create'
        ServiceLevelComponentImporter.new(callback_url).create
      when 'update'
        ServiceLevelComponentImporter.new(callback_url).update
      when 'destroy'
        ServiceLevelComponentImporter.new(callback_url).destroy
      end
    }
  end
end
