class ImporterJob < Struct.new(:sparc_id, :callback_url, :action)

  class SparcApiError < StandardError
  end

  def self.enqueue(sparc_id, callback_url, action)
    job = new(sparc_id, callback_url, action)

    Delayed::Job.enqueue job, queue: 'sparc_api_requests'
  end

  def perform
    skip_faye_callbacks
    yield
    set_faye_callbacks
  end

  private

  # Disable #update_faye callback on save
  def skip_faye_callbacks
    Protocol.skip_callback    :save, :after, :update_faye
    Participant.skip_callback :save, :after, :update_faye
  end

  # Enable #update_faye callback on save
  def set_faye_callbacks
    Protocol.set_callback    :save, :after, :update_faye
    Participant.set_callback :save, :after, :update_faye
  end

  def update_faye(object)
    FayeJob.enqueue(object)
  end
end
