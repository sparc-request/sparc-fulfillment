class ProtocolImporterJob < ImporterJob

  def perform sparc_id, callback_url, action
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
