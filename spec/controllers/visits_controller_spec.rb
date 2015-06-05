require 'rails_helper'

RSpec.describe VisitsController, type: :controller do
  before :each do
    sign_in
    create_and_assign_protocol_to_me
    @visit = Visit.first
  end

  describe "PUT #update" do
    it "should update the quantity" do
      put :update, {
        id: @visit.id,
        visit: {research_billing_qty: 5},
        format: :js
      }
      @visit.reload
      expect(@visit.research_billing_qty).to eq 5
    end
  end
end