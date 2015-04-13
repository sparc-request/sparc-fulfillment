class ServiceImporterJob < ImporterJob

  def perform
    super {
      case action
      when 'create'
        ServiceImporter.new(callback_url).create
      when 'update'
        ServiceImporter.new(callback_url).update(sparc_id)
      when 'destroy'
        #destroy
      end
    }
  end
end
