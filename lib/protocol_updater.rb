class ProtocolUpdater

  def initialize(json, protocol_id)
    @json         = json
    @protocol_id  = protocol_id
  end

  def import!
    protocol.update_attributes(filtered_json)
  end

  private

  def filtered_json
    parsed_json.reject { |key, value| !protocol_attributes.include?(key) }
  end

  def protocol_attributes
    protocol.attributes.reject { |key, value| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.keys
  end

  def parsed_json
    JSON.parse @json
  end

  def protocol
    @protocol ||= Protocol.find @protocol_id
  end
end
