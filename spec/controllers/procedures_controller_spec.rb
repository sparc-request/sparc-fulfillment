require 'rails_helper'

RSpec.describe ProceduresController, type: :controller do

  login_user

  before :each do
    @appointment  = create(:appointment, :participant_id => 1, :name => "Visit 1", :arm_id => 1)
    @service      = create(:service)
  end

  describe 'PUT #update' do

    context 'with Notable change' do

      context 'Procedure status is not set' do

        context 'User marks Procedure as complete' do

          before do
            procedure = create(:procedure)
            params    = { id: procedure.id, procedure: { status: 'complete' }, format: :js }

            put :update, params
          end

          it 'should update the Procedure status' do
            expect(assigns(:procedure).status).to eq('complete')
          end

          it 'should update the Procedure completed_date to: Time.current' do
            expect(assigns(:procedure).completed_date).to be
          end

          it 'should create a Note' do
            expect(assigns(:procedure).reload.notes).to be_one
          end
        end

        context 'User edits completed_date' do
           before do
            procedure = create(:procedure, status: 'complete', completed_date: '01-01-2024')
            params    = { id: procedure.id, procedure: { completed_date: '01-01-2025' }, format: :js }

            put :update, params
          end

          it "should update the completed date" do
            expect(assigns(:procedure).completed_date).to eq Time.parse "01/01/2025"
          end

          it "should create a note" do
            expect(assigns(:procedure).reload.notes).to be_two
          end
        end


        context 'User marks Procedure as incomplete' do

          before do
            procedure = create(:procedure)
            params    = { id: procedure.id, procedure: { status: 'incomplete' }, format: :js }

            put :update, params
          end

          it 'should update the Procedure status' do
            expect(assigns(:procedure).status).to eq('incomplete')
          end

          it 'should update the Procedure completed_date to: nil' do
            expect(assigns(:procedure).completed_date).to_not be
          end

          it 'should create a Note' do
            expect(assigns(:procedure).reload.notes).to be_one
          end
        end
      end

      context 'Procedure status is: complete' do

        context 'User marks Procedure as complete' do

          before do
            procedure = create(:procedure_complete)
            params    = { id: procedure.id, procedure: { status: 'complete' }, format: :js }

            put :update, params
          end

          it 'should update the Procedure status' do
            expect(assigns(:procedure).status).to eq('complete')
          end

          it 'should update the Procedure completed_date to: Time.current' do
            expect(assigns(:procedure).completed_date).to be
          end

          it 'should not create a Note' do
            expect(assigns(:procedure).reload.notes.count).to be_zero
          end
        end

        context 'User marks Procedure as incomplete' do

          before do
            procedure = create(:procedure_complete)
            params    = { id: procedure.id, procedure: { status: 'incomplete', completed_date: "" }, format: :js }

            put :update, params
          end

          it 'should update the Procedure status' do
            expect(assigns(:procedure).status).to eq('incomplete')
          end

          it 'should update the Procedure completed_date to: nil' do
            expect(assigns(:procedure).reload.completed_date).to_not be
          end

          it 'should create a Note' do
            expect(assigns(:procedure).reload.notes).to be_one
          end
        end
      end

      context 'Procedure status is: incomplete' do

        context 'User marks Procedure as complete' do

          before do
            procedure = create(:procedure_complete)
            params    = { id: procedure.id, procedure: { status: 'complete' }, format: :js }

            put :update, params
          end

          it 'should update the Procedure status' do
            expect(assigns(:procedure).status).to eq('complete')
          end

          it 'should update the Procedure completed_date to: Time.current' do
            expect(assigns(:procedure).completed_date).to be
          end

          it 'should not create a Note' do
            expect(assigns(:procedure).reload.notes.count).to be_zero
          end
        end

        context 'User marks Procedure as incomplete' do

          before do
            procedure = create(:procedure_complete)
            params    = { id: procedure.id, procedure: { status: 'incomplete', completed_date: "" }, format: :js }

            put :update, params
          end

          it 'should update the Procedure status' do
            expect(assigns(:procedure).status).to eq('incomplete')
          end

          it 'should update the Procedure completed_date to: nil' do
            expect(assigns(:procedure).reload.completed_date).to_not be
          end

          it 'should create a Note' do
            expect(assigns(:procedure).reload.notes).to be_one
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

