require 'rails_helper'

RSpec.describe FulfillmentsController do

  before :each do
    sign_in
    @line_item = create(:line_item, protocol: create(:protocol), service: create(:service))
    @fulfillment = create(:fulfillment, line_item: @line_item)
  end

end
