class SubServiceRequestUpdater

  def initialize(json, sub_service_request_id)
    @json                   = json
    @sub_service_request_id = sub_service_request_id
  end

  def import!
    # protocol.update_attributes(parsed_json[0])
  end

  private

  def parsed_json
    JSON.parse @json, symbolize_names: true
  end
end
