# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

            put :update, params: params
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

            put :update, params: params
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
            put :update, params: params
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

            put :update, params: params
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

            put :update, params: params
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

            put :update, params: params
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

            put :update, params: params
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
        post :create, params: {
          appointment_id: @appointment.id,
          qty: qty,
          service_id: @service.id
          }, format: :js
        }.to change(Procedure, :count).by(qty)
    end
  end

  describe "DELETE #delete" do
    it "should remove the procedure if unmarked" do
      @procedure = create(:procedure, appointment: @appointment, service: @service)
      expect{
        delete :destroy, params: {
          id: @procedure.id
          }, format: :js
        }.to change(Procedure, :count).by(-1)
    end

    it "should not remove the procedure if marked as completed" do
      @procedure = create(:procedure, appointment: @appointment, service: @service, status: 'complete')
      expect{
        delete :destroy, params: {
          id: @procedure.id
          }, format: :js
        }.to raise_error(ActiveRecord::ActiveRecordError)
    end

    it "should not remove the procedure if marked as incomplete" do
      @procedure = create(:procedure, appointment: @appointment, service: @service, status: 'incomplete')
      expect{
        delete :destroy, params: {
          id: @procedure.id
          }, format: :js
        }.to raise_error(ActiveRecord::ActiveRecordError)
    end
  end
end
