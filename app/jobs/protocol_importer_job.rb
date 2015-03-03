class ProtocolImporterJob < ImporterJob

  def perform
    super {
      case action
      when 'create'
        #create
      when 'update'
        ProtocolImporter.new(callback_url).create
      when 'destroy'
        #destroy
      end
    }
  end
end
