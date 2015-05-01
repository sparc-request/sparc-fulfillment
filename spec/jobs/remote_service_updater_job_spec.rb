require 'rails_helper'

RSpec.describe RemoteServiceUpdaterJob, type: :job do

  describe "#perform", vcr: true do

    it "should make a request to the SPARC server" do
      service = create(:service)

      RemoteServiceUpdaterJob.perform_now(service, 1)

      expect(a_request(:put, /#{ENV['SPARC_API_HOST']}/).
        with(body: '{"service":{"line_items_count":1}}')).
        to have_been_made.once
    end
  end
end
