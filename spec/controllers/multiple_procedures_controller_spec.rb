# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

RSpec.describe MultipleProceduresController, type: :controller do

  before :each do

    @identity = create(:identity)
    sign_in @identity

    @service     = create(:service)
    protocol     = create(:protocol_imported_from_sparc)
    arm          = protocol.arms.first
    participant  = create(:participant)
    protocols_participant = create(:protocols_participant, arm: arm, protocol: protocol, participant: participant)
    @appointment = create(:appointment, name: "Visit Test", arm: arm, protocols_participant: protocols_participant)
  end

  describe 'PUT #update_procedures' do

    context 'with Notable change' do

      context 'Procedures statuses are unstarted' do

        context 'User marks Procedures as complete' do

          before do
            @procedure1 = create(:procedure, appointment: @appointment, service: @service)
            @procedure2 = create(:procedure, appointment: @appointment, service: @service)
            @current_date = DateTime.current
            params = { procedure_ids: [@procedure1.id, @procedure2.id], status: 'complete', completed_date: @current_date.strftime("%m/%d/%Y"), performed_by: @identity.id, format: :js }

            put :update_procedures, params: params
          end

          it 'should update the Procedures statuses' do
            expect(@procedure1.reload.status).to eq("complete")
            expect(@procedure2.reload.status).to eq("complete")
          end

          it 'should upDateTime the Procedure completed_date to: Time.current' do
            expect((@procedure1.reload.completed_date).to_date).to eq(@current_date.to_date)
            expect((@procedure2.reload.completed_date).to_date).to eq(@current_date.to_date)
          end

          it 'should update the Procedure incompleted_date to: nil' do
            expect(@procedure1.reload.incompleted_date).to eq(nil)
            expect(@procedure2.reload.incompleted_date).to eq(nil)
          end
        end

        context 'User marks Procedure as incomplete' do

          before do
            @procedure1 = create(:procedure, appointment: @appointment, service: @service)
            @procedure2 = create(:procedure, appointment: @appointment, service: @service)
            @current_date = DateTime.current
            params    = { procedure_ids: [@procedure1.id, @procedure2.id], status: 'incomplete', performed_by: @identity.id, reason: "Assessment missed", comment: "Hello Beautiful", format: :js }

            put :update_procedures, params: params
          end

          it 'should update the Procedures statuses' do
            expect(@procedure1.reload.status).to eq("incomplete")
            expect(@procedure2.reload.status).to eq("incomplete")
          end

          it 'should update the Procedure completed_date to: nil' do
            expect(@procedure1.reload.completed_date).to eq(nil)
            expect(@procedure2.reload.completed_date).to eq(nil)
          end

          it 'should update the Procedure incompleted_date to: todays date' do
            expect((@procedure1.reload.incompleted_date).to_date).to eq(@current_date.to_date)
            expect((@procedure2.reload.incompleted_date).to_date).to eq(@current_date.to_date)
          end

          it 'should create a Note' do
            expect(@procedure1.reload.notes).to be
            expect(@procedure2.reload.notes).to be
          end

          it 'should update the Procedures reasons' do
            expect(@procedure1.reload.notes.last.reason).to eq('Assessment missed')
            expect(@procedure2.reload.notes.last.reason).to eq('Assessment missed')
          end

          it 'should update the Procedures comments for the second note' do
            expect(@procedure1.reload.notes.last.comment).to eq('Assessment missed: Hello Beautiful')
            expect(@procedure2.reload.notes.last.comment).to eq('Assessment missed: Hello Beautiful')
          end

          it 'should update the Procedures comments for the first note' do
            expect(@procedure1.reload.notes.first.comment).to eq('Status set to incomplete')
            expect(@procedure2.reload.notes.first.comment).to eq('Status set to incomplete')
          end
        end
      end

      context 'Procedure status is: complete' do

        context 'User edits fields for all complete Procedures' do
          before do
            @procedure1 = create(:procedure_complete, appointment: @appointment, service: @service, performer_id: @identity.id)
            @procedure2 = create(:procedure_complete, appointment: @appointment, service: @service, performer_id: @identity.id)
            @edited_date = DateTime.current.tomorrow
            params = { procedure_ids: [@procedure1.id, @procedure2.id], status: 'complete', completed_date: @edited_date.strftime("%m/%d/%Y"), performed_by: Identity.last.id, format: :js }

            put :update_procedures, params: params
          end

          it "should update the completed date" do
            expect((@procedure1.reload.completed_date).to_date).to eq(@edited_date.to_date)
            expect((@procedure2.reload.completed_date).to_date).to eq(@edited_date.to_date)
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
            @current_date = DateTime.current
            params    = { procedure_ids: [@procedure1.id, @procedure2.id], status: 'incomplete', performed_by: @identity.id, reason: "Assessment missed", comment: "Hello Beautiful", format: :js }

            put :update_procedures, params: params
          end

          it 'should update the Procedure statuses' do
            expect(@procedure1.reload.status).to eq("incomplete")
            expect(@procedure2.reload.status).to eq("incomplete")
          end

          it 'should update the Procedures completed_dates to: nil' do
            expect(@procedure1.reload.completed_date).to eq(nil)
            expect(@procedure2.reload.completed_date).to eq(nil)
          end

          it 'should update the Procedures incompleted_dates to: current date' do
            expect((@procedure1.reload.incompleted_date).to_date).to eq(@current_date.to_date)
            expect((@procedure2.reload.incompleted_date).to_date).to eq(@current_date.to_date)
          end

          it 'should create a Note' do
            expect(@procedure1.reload.notes).to be
            expect(@procedure2.reload.notes).to be
          end

          it 'should update the Procedures reasons' do
            expect(@procedure1.reload.notes.last.reason).to eq('Assessment missed')
            expect(@procedure2.reload.notes.last.reason).to eq('Assessment missed')
          end

          it 'should update the Procedures comments for the second note' do
            expect(@procedure1.reload.notes.last.comment).to eq('Assessment missed: Hello Beautiful')
            expect(@procedure2.reload.notes.last.comment).to eq('Assessment missed: Hello Beautiful')
          end

          it 'should update the Procedures comments for the first note' do
            expect(@procedure1.reload.notes.first.comment).to eq('Status set to incomplete')
            expect(@procedure2.reload.notes.first.comment).to eq('Status set to incomplete')
          end
        end
      end

      context 'Procedure status is: incomplete' do

        context 'User marks Procedure as complete' do

          before do
            @procedure1 = create(:procedure, status: "incomplete", appointment: @appointment, service: @service, performer_id: @identity.id)
            @procedure2 = create(:procedure, status: "incomplete", appointment: @appointment, service: @service, performer_id: @identity.id)
            @edited_date = DateTime.current.tomorrow
            params    = { procedure_ids: [@procedure1.id, @procedure2.id], status: 'complete', completed_date: @edited_date.strftime("%m/%d/%Y"), performed_by: Identity.first.id, format: :js }

            put :update_procedures, params: params
          end

          it 'should update the Procedure statuses' do
            expect(@procedure1.reload.status).to eq("complete")
            expect(@procedure2.reload.status).to eq("complete")
          end

          it 'should update the Procedure completed_date to: edited_date' do
            expect((@procedure1.reload.completed_date).to_date).to eq(@edited_date.to_date)
            expect((@procedure2.reload.completed_date).to_date).to eq(@edited_date.to_date)
          end

          it 'should update the Procedures incompleted_dates to: nil' do
            expect(@procedure1.reload.incompleted_date).to eq(nil)
            expect(@procedure2.reload.incompleted_date).to eq(nil)
          end

          it 'should create a Note' do
            expect(@procedure1.reload.notes).to be
            expect(@procedure2.reload.notes).to be
          end
        end
        context 'User edits fields for all incomplete Procedures' do

          before do
            @procedure1 = create(:procedure_incomplete, appointment: @appointment, service: @service, performer_id: @identity.id)
            @procedure2 = create(:procedure_incomplete, appointment: @appointment, service: @service, performer_id: @identity.id)
            @current_date = DateTime.current
            params    = { procedure_ids: [@procedure1.id, @procedure2.id], status: 'incomplete', performed_by: Identity.first.id, reason: "Assessment missed", format: :js }

            put :update_procedures, params: params
          end

          it 'should update the Procedure statuses' do
            expect(@procedure1.reload.status).to eq("incomplete")
            expect(@procedure2.reload.status).to eq("incomplete")
          end

          it 'should update the Procedure incompleted_date to: current date' do
            expect((@procedure1.reload.incompleted_date).to_date).to eq(@current_date.to_date)
            expect((@procedure2.reload.incompleted_date).to_date).to eq(@current_date.to_date)
          end

          it 'should update the Procedures completed_dates to: nil' do
            expect(@procedure1.reload.completed_date).to eq(nil)
            expect(@procedure2.reload.completed_date).to eq(nil)
          end

          it 'should create a Note' do
            expect(@procedure1.reload.notes).to be
            expect(@procedure2.reload.notes).to be
          end
        end
      end
    end
  end
end
