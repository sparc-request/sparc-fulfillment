require 'rails_helper'

RSpec.describe ProceduresController, type: :controller do
  before :each do
    sign_in
    @appointment = create(:appointment)
    @service = create(:service)
  end

  describe "POST #create" do
    it "should create the indicated number of procedures" do
      qty = 5
      expect{
        post :create, {
          appointment_id: @appointment.id,
          qty: qty,
          service_id: @service.id,
          format: :js
          }
        }.to change(Procedure, :count).by(qty)
    end
  end
end

