class ImporterJob < ActiveJob::Base
  queue_as :sparc_api_requests

  class SparcApiError < StandardError
  end

  def perform sparc_id, callback_url, action
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
    FayeJob.perform_later object
  end
end
