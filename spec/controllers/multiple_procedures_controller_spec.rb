require 'rails_helper'

RSpec.describe MultipleProceduresController, type: :controller do

  before :each do

    @identity = create(:identity)
    sign_in @identity

    @service     = create(:service)
    protocol     = create(:protocol_imported_from_sparc)
    arm          = protocol.arms.first
    participant  = arm.participants.first
    @appointment = create(:appointment, name: "Visit Test", arm: arm, participant: participant)
  end

  describe 'PUT #update_procedures' do

    context 'with Notable change' do

      context 'Procedures statuses are unstarted' do

        context 'User marks Procedures as complete' do
          #params:  procedure_ids"=>["2838", "2839", "2840"], "status"=>"complete", "completed_date"=>"04-22-2016", "performed_by"=>"12911"

          before do
            @procedure1 = create(:procedure, appointment: @appointment, service: @service)
            @procedure2 = create(:procedure, appointment: @appointment, service: @service)
            @current_date = Date.current.strftime("%m-%d-%Y")
            params = { procedure_ids: [@procedure1.id, @procedure2.id], status: 'complete', completed_date: @current_date, performed_by: @identity.id, format: :js }

            put :update_procedures, params
          end

          it 'should update the Procedures statuses' do
            expect(@procedure1.reload.status).to eq("complete")
            expect(@procedure2.reload.status).to eq("complete")
          end

          it 'should update the Procedure completed_date to: Time.current' do
            expect(@procedure1.reload.completed_date).to eq(Time.strptime(@current_date, "%m-%d-%Y"))
            expect(@procedure2.reload.completed_date).to eq(Time.strptime(@current_date, "%m-%d-%Y"))
          end

          it 'should update the Procedure incompleted_date to: nil' do
            expect(@procedure1.reload.incompleted_date).to eq(nil)
            expect(@procedure2.reload.incompleted_date).to eq(nil)
          end

        end

        context 'User marks Procedure as incomplete' do
          # "procedure_ids"=>["2838", "2839", "2840"], "status"=>"incomplete", "incompleted_date"=>"04-22-2016", "performed_by"=>"12911", "reason"=>"Assessment missed", "comment"=>""}

          before do
            @procedure1 = create(:procedure, appointment: @appointment, service: @service)
            @procedure2 = create(:procedure, appointment: @appointment, service: @service)
            @current_date = Date.current.strftime("%m-%d-%Y")
            params    = { procedure_ids: [@procedure1.id, @procedure2.id], status: 'incomplete', incompleted_date: @current_date, performed_by: @identity.id, reason: "Assessment missed", comment: "Hello Beautiful", format: :js }

            put :update_procedures, params
          end

          it 'should update the Procedures statuses' do
            expect(@procedure1.reload.status).to eq("incomplete")
            expect(@procedure2.reload.status).to eq("incomplete")
          end

          it 'should update the Procedure completed_date to: nil' do
            expect(@procedure1.reload.completed_date).to eq(nil)
            expect(@procedure2.reload.completed_date).to eq(nil)
          end

          it 'should create a Note' do
            expect(@procedure1.reload.notes).to be
            expect(@procedure2.reload.notes).to be
          end

          it 'should update the Procedures reasons' do
            expect(@procedure1.reload.notes.first.reason).to eq('Assessment missed')
            expect(@procedure2.reload.notes.first.reason).to eq('Assessment missed')
          end

           it 'should update the Procedures comments' do
            expect(@procedure1.reload.notes.first.comment).to eq('Assessment missed: Hello Beautiful')
            expect(@procedure2.reload.notes.first.comment).to eq('Assessment missed: Hello Beautiful')
          end
        end
      end

      context 'Procedure status is: complete' do

        context 'User edits fields for all complete Procedures' do
          before do
            @procedure1 = create(:procedure_complete, appointment: @appointment, service: @service, performer_id: @identity.id)
            @procedure2 = create(:procedure_complete, appointment: @appointment, service: @service, performer_id: @identity.id)
            @edited_date = Date.current.tomorrow.strftime("%m-%d-%Y")
            params = { procedure_ids: [@procedure1.id, @procedure2.id], status: 'complete', completed_date: @edited_date, performed_by: Identity.last.id, format: :js }

            put :update_procedures, params
          end

          it "should update the completed date" do
            expect(@procedure1.reload.completed_date).to eq(Time.strptime(@edited_date, "%m-%d-%Y"))
            expect(@procedure2.reload.completed_date).to eq(Time.strptime(@edited_date, "%m-%d-%Y"))
          end

          it "should update the performer_id" do
            expect(@procedure1.reload.performer_id).to eq(Identity.last.id)
            expect(@procedure2.reload.performer_id).to eq(Identity.last.id)
          end

          it "should create a note" do
            expect(@procedure1.reload.notes).to be
            expect(@procedure2.reload.notes).to be
          end
        end

        context 'User marks Procedure as incomplete' do

          before do
            @procedure1 = create(:procedure_complete, appointment: @appointment, service: @service, performer_id: @identity.id)
            @procedure2 = create(:procedure_complete, appointment: @appointment, service: @service, performer_id: @identity.id)
            @edited_date = Date.current.tomorrow.strftime("%m-%d-%Y")
            params    = { procedure_ids: [@procedure1.id, @procedure2.id], status: 'incomplete', incompleted_date: @edited_date, performed_by: @identity.id, reason: "Assessment missed", comment: "Hello Beautiful", format: :js }

            put :update_procedures, params
          end

          it 'should update the Procedure statuses' do
            expect(@procedure1.reload.status).to eq("incomplete")
            expect(@procedure2.reload.status).to eq("incomplete")
          end

          it 'should update the Procedures completed_dates to: nil' do
            expect(@procedure1.reload.completed_date).to eq(nil)
            expect(@procedure2.reload.completed_date).to eq(nil)
          end

          it 'should update the Procedures completed_dates to: edited_date' do
            expect(@procedure1.reload.incompleted_date).to eq(Time.strptime(@edited_date, "%m-%d-%Y"))
            expect(@procedure2.reload.incompleted_date).to eq(Time.strptime(@edited_date, "%m-%d-%Y"))
          end

          it 'should create a Note' do
            expect(@procedure1.reload.notes).to be
            expect(@procedure2.reload.notes).to be
          end

          it 'should update the Procedures reasons' do
            expect(@procedure1.reload.notes.first.reason).to eq('Assessment missed')
            expect(@procedure2.reload.notes.first.reason).to eq('Assessment missed')
          end

          it 'should update the Procedures comments' do
            expect(@procedure1.reload.notes.first.comment).to eq('Assessment missed: Hello Beautiful')
            expect(@procedure2.reload.notes.first.comment).to eq('Assessment missed: Hello Beautiful')
          end
        end
      end

      context 'Procedure status is: incomplete' do

        context 'User marks Procedure as complete' do

          before do
            @procedure1 = create(:procedure, status: "incomplete", appointment: @appointment, service: @service, performer_id: @identity.id)
            @procedure2 = create(:procedure, status: "incomplete", appointment: @appointment, service: @service, performer_id: @identity.id)
            @edited_date = Date.current.tomorrow.strftime("%m-%d-%Y")
            params    = { procedure_ids: [@procedure1.id, @procedure2.id], status: 'complete', completed_date: @edited_date, performed_by: Identity.first.id, format: :js }

            put :update_procedures, params
          end

          it 'should update the Procedure statuses' do
            
          end

          it 'should update the Procedure completed_date to: edited_date' do
            
          end

          it 'should create a Note' do
            
          end
        end
      end

      #   context 'User marks Procedure as incomplete' do

      #     before do
      #       procedure = create(:procedure, appointment: @appointment, service: @service)
      #       params    = { id: procedure.id, procedure: { status: 'incomplete'}, format: :js }

      #       put :update, params
      #     end

      #     it 'should update the Procedure status' do
      #       expect(assigns(:procedure).status).to eq('incomplete')
      #     end

      #     it 'should create a Note' do
      #       expect(assigns(:procedure).reload.notes).to be_one
      #     end

      #     it 'should set the incomplete date to today' do
      #       expect(assigns(:procedure).incompleted_date.to_date).to eq(Date.today)
      #     end
      #   end
    end
  end

end
