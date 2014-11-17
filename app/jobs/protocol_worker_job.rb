class ProtocolWorkerJob < Struct.new(:protocol_id, :ssr_id, :new_record)

  def perform
    url = "http://localhost:3000/v1/protocols/#{protocol_id}.json"
    begin
      if new_record
        response = RestClient.get url, {id: protocol_id, ssr_id: ssr_id}, content_type: 'application/json'
        puts response.inspect
      else
        # response = RestClient.patch url, {id: protocol_id}, content_type: 'application.json'
      end
    rescue => e
      puts e.inspect
      Rails.logger.debug(e)
    end
  end

  def self.enqueue protocol_id, ssr_id, new_record
    job = new protocol_id, ssr_id, new_record
    Delayed::Job.enqueue job
  end

end