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

  describe "DELETE #delete" do
    it "should remove the procedure if unmarked" do
      @procedure = create(:procedure, appointment_id: @appointment.id)
      expect{
        delete :destroy, {
          id: @procedure.id,
          format: :js
          }
        }.to change(Procedure, :count).by(-1)
    end

    it "should not remove the procedure if marked as completed" do
      @procedure = create(:procedure, appointment_id: @appointment.id, status: 'completed')
      expect{
        delete :destroy, {
          id: @procedure.id,
          format: :js
          }
        }.to raise_error(ActiveRecord::ActiveRecordError)
    end

    it "should not remove the procedure if marked as incomplete" do
      @procedure = create(:procedure, appointment_id: @appointment.id, status: 'incomplete')
      expect{
        delete :destroy, {
          id: @procedure.id,
          format: :js
          }
        }.to raise_error(ActiveRecord::ActiveRecordError)
    end
  end
end

