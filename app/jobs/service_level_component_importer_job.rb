class ServiceLevelComponentImporterJob < ImporterJob

  def perform
    super {
      case action
      when 'create'
        #create
      when 'update'
        ServiceLevelComponentImporter.new(callback_url).update(sparc_id)
      when 'destroy'
        #destroy
      end
    }
  end
end
