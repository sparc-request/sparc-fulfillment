require 'rails_helper'

RSpec.describe ProceduresController, type: :controller do

  login_user

  before :each do
    @appointment  = create(:appointment)
    @service      = create(:service)
  end

  describe 'PUT #update' do

    context 'with Notable change' do

      before do
        procedure = create(:procedure)
        params    = { id: procedure.id, procedure: { status: 'complete' }, format: :js }

        put :update, params
      end

      it 'should update the Procedure status' do
        expect(assigns(:procedure).status).to eq('complete')
      end

      it 'should create a Note' do
        expect(assigns(:procedure).notes.one?).to be
      end
    end

    context 'without Notable change' do

      before do
        procedure = create(:procedure_complete)
        params    = { id: procedure.id, procedure: { status: 'complete' }, format: :js }

        put :update, params
      end

      it 'should update the Procedure status' do
        expect(assigns(:procedure).status).to eq('complete')
      end

      it 'should not create a Note' do
        expect(assigns(:procedure).notes.one?).to_not be
      end
    end
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
      @procedure = create(:procedure, appointment_id: @appointment.id, status: 'complete')
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

