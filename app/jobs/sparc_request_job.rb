class SparcRequestJob < ActiveJob::Base

  queue_as :sparc_api_requests

  class SparcApiError < StandardError
  end
end
