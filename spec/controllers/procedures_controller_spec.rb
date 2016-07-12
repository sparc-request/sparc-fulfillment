require 'rails_helper'

RSpec.describe ProceduresController, type: :controller do

  login_user

  before :each do
    @service     = create(:service)
    protocol     = create(:protocol_imported_from_sparc)
    arm          = protocol.arms.first
    participant  = arm.participants.first
    @appointment = create(:appointment, name: "Visit Test", arm: arm, participant: participant)
  end

  describe 'PUT #update' do

    context 'with Notable change' do

      context 'Procedure status is unstarted' do

        context 'User marks Procedure as complete' do

          before do
            @procedure = create(:procedure, appointment: @appointment, service: @service)
            params = { id: @procedure.id, procedure: { status: 'complete' }, format: :js }

            put :update, params
          end

          it 'should update the Procedure status' do
            expect(@procedure.reload.status).to eq('complete')
          end

          it 'should update the Procedure completed_date to: Time.current' do
            expect(@procedure.reload.completed_date).to be
          end

          it 'should create a Note' do
            expect(@procedure.reload.notes).to be_one
          end
        end

        context 'User marks Procedure as incomplete' do

          before do
            @procedure = create(:procedure, appointment: @appointment, service: @service)
            params    = { id: @procedure.id, procedure: { status: 'incomplete' }, format: :js }

            put :update, params
          end

          it 'should update the Procedure status' do
            expect(@procedure.reload.status).to eq('incomplete')
          end

          it 'should update the Procedure completed_date to: nil' do
            expect(@procedure.reload.completed_date).to_not be
          end

          it 'should create a Note' do
            expect(@procedure.reload.notes).to be_one
          end
        end
      end

      context 'Procedure status is: complete' do

        context 'User edits completed_date' do

          before do
            @procedure = create(:procedure_complete, appointment: @appointment, service: @service)
            params    = { id: @procedure.id, procedure: { completed_date: DateTime.current.tomorrow.strftime("%m/%d/%Y")}, format: :js }
            put :update, params
          end

          it "should update the completed date" do
            expect(@procedure.reload.completed_date.strftime("%m/%d/%Y")).to eq DateTime.current.tomorrow.strftime("%m/%d/%Y")
          end

          it "should create a note" do
            expect(@procedure.reload.notes).to be_one
          end
        end

        context 'User marks the procedure as complete' do #if the procedure is already complete, a user setting it to complete again will render the status void
          before do
            @procedure = create(:procedure_complete, appointment: @appointment, service: @service)
            params = { id: @procedure.id, procedure: { status: 'unstarted' }, format: :js }

            put :update, params
          end

          it "should update the completed_date to be nil" do
            expect(@procedure.reload.completed_date).to_not be
          end

          it "should update the status to be unstarted" do
            expect(@procedure.reload.status).to eq 'unstarted'
          end

          it "should create a note" do
            expect(@procedure.reload.notes).to be_one
          end
        end

        context 'User marks Procedure as incomplete' do

          before do
            @procedure = create(:procedure_complete, appointment: @appointment, service: @service)
            params    = { id: @procedure.id, procedure: { status: 'incomplete', completed_date: "" }, format: :js }

            put :update, params
          end

          it 'should update the Procedure status' do
            expect(@procedure.reload.status).to eq('incomplete')
          end

          it 'should update the Procedure completed_date to: nil' do
            expect(@procedure.reload.completed_date).to_not be
          end

          it 'should create a Note' do
            expect(@procedure.reload.notes).to be_one
          end
        end
      end

      context 'Procedure status is: incomplete' do

        context 'User marks Procedure as complete' do

          before do
            @procedure = create(:procedure, appointment: @appointment, service: @service)
            params    = { id: @procedure.id, procedure: { status: 'complete' }, format: :js }

            put :update, params
          end

          it 'should update the Procedure status' do
            expect(@procedure.reload.status).to eq('complete')
          end

          it 'should update the Procedure completed_date to: Time.current' do
            expect(@procedure.reload.completed_date).to be
          end

          it 'should create a Note' do
            expect(@procedure.reload.notes).to be_one
          end
        end

        context 'User marks Procedure as incomplete' do

          before do
            @procedure = create(:procedure, appointment: @appointment, service: @service)
            params    = { id: @procedure.id, procedure: { status: 'incomplete'}, format: :js }

            put :update, params
          end

          it 'should update the Procedure status' do
            expect(@procedure.reload.status).to eq('incomplete')
          end

          it 'should create a Note' do
            expect(@procedure.reload.notes).to be_one
          end

          it 'should set the incomplete date to today' do
            expect(@procedure.reload.incompleted_date.to_date).to eq(Date.today)
          end
        end
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
      @procedure = create(:procedure, appointment: @appointment, service: @service)
      expect{
        delete :destroy, {
          id: @procedure.id,
          format: :js
          }
        }.to change(Procedure, :count).by(-1)
    end

    it "should not remove the procedure if marked as completed" do
      @procedure = create(:procedure, appointment: @appointment, service: @service, status: 'complete')
      expect{
        delete :destroy, {
          id: @procedure.id,
          format: :js
          }
        }.to raise_error(ActiveRecord::ActiveRecordError)
    end

    it "should not remove the procedure if marked as incomplete" do
      @procedure = create(:procedure, appointment: @appointment, service: @service, status: 'incomplete')
      expect{
        delete :destroy, {
          id: @procedure.id,
          format: :js
          }
        }.to raise_error(ActiveRecord::ActiveRecordError)
    end
  end
end
